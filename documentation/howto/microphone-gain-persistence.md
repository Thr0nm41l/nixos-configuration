# Fix: Microphone Gain Not Persisting After Reboot

## Context

With PipeWire + WirePlumber, hardware gain controls (mic boost, capture gain) are ALSA-level controls that WirePlumber manages directly. Traditional `alsactl store/restore` is unreliable because WirePlumber re-initialises ALSA devices after the restore runs, overriding the saved state.

The proper fix is to configure WirePlumber to apply the desired gain value via an ALSA monitor rule that targets your specific hardware control.

---

## Step 1 — Find your microphone's stable card name

Node names (e.g. `alsa_input.pci-0000_00_1f.3.analog-stereo`) can shift between reboots if card detection order changes. Use `api.alsa.card.name` instead — it is tied to the hardware and stays consistent.

Find your card names:

```bash
cat /proc/asound/cards
```

Example output:
```
 0 [Generic        ]: HDA-Intel - HD Audio Generic
 1 [NVidia         ]: HDA-Intel - HDA NVidia
```

Note the card name in brackets (e.g. `HD Audio Generic`). This maps to `api.alsa.card.name` in WirePlumber rules.

You can also confirm via WirePlumber:

```bash
wpctl status | grep -A30 "Sources"
```

Look for your microphone — NVIDIA entries should already be disabled by the `51-mic-restore` rule.

---

## Step 2 — Find your microphone's ALSA capture control name

```bash
amixer -c 0 scontrols
```

This lists all ALSA controls on card 0. Look for controls related to input, such as:
- `Capture`
- `Mic Boost`
- `Internal Mic Boost`
- `Digital Capture Volume`

To see the current value and range of a specific control:

```bash
amixer -c 0 sget "Capture"
```

Example output:
```
Simple mixer control 'Capture',0
  Limits: Capture 0 - 63
  Mono: Capture 40 [63%] [-17.50dB]
```

Note the control name (e.g. `"Capture"`) and your desired value.

---

## Step 3 — Set gain to the desired level temporarily

Use `alsamixer` (interactive TUI) or `amixer` directly:

```bash
# Set capture gain to a specific value (replace 40 with your desired level)
amixer -c 0 sset "Capture" 40
```

Adjust until the microphone sounds right, then note the value.

---

## Step 4 — Add a WirePlumber ALSA rule in configuration.nix

Add a new rule inside `services.pipewire.wireplumber.extraConfig` in `configuration.nix`, targeting your specific node and control:

```nix
wireplumber.extraConfig."52-mic-gain" = {
  "monitor.alsa.rules" = [
    {
      # Match by card name — stable across reboots unlike node names
      matches = [{ "api.alsa.card.name" = "~HD Audio Generic*"; }];
      actions = {
        update-props = {
          "audio.volume" = 0.75;
        };
        # Set hardware ALSA control values on node creation
        "mixer-controls" = [
          { "control" = "Capture"; "value" = 40; }
          { "control" = "Mic Boost"; "value" = 1; }
        ];
      };
    }
  ];
};
```

Replace:
- `~HD Audio Generic*` → your card name from Step 1 (use `~` prefix for glob matching)
- `"Capture"` / `"Mic Boost"` → your control names from Step 2
- `40` / `1` → your desired values from Step 3

Then rebuild: `update`

---

## Step 5 — Verify after reboot

After rebuilding and rebooting, check that the gain held:

```bash
amixer -c 0 sget "Capture"
```

If it still resets, double-check the node name and control name match exactly (they are case-sensitive).

---

## Note on the existing volume rule

The existing `51-mic-restore` rule in `configuration.nix` already handles software volume (`audio.volume = 0.75`) for all input nodes. The new `52-mic-gain` rule complements it by targeting hardware gain for your specific device. Both can coexist.
