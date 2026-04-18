# Fix: Microphone Settings Reset to Max After Reboot

## Root cause

WirePlumber (PipeWire's session manager) is supposed to save and restore device state between reboots via `~/.local/state/wireplumber/`. However, on some hardware the ALSA UCM (Use Case Manager) profile resets input device gain and volume to their hardware maximums during boot before WirePlumber can restore its saved state. This results in mic volume, gain, and sensitivity being maxed out after every reboot.

---

## Fix applied

A WirePlumber ALSA monitor rule was added to `configuration.nix` inside `services.pipewire`:

```nix
wireplumber.extraConfig."51-mic-restore" = {
  "monitor.alsa.rules" = [
    {
      matches = [{ "node.name" = "~alsa_input.*"; }];
      actions = {
        update-props = {
          "node.pause-on-idle" = false;
          "audio.volume" = 0.75;
        };
      };
    }
  ];
};
```

**What it does:**
- Matches all ALSA input nodes (microphones) on startup via the `alsa_input.*` pattern
- Sets their volume to 75% (`0.75`) — overriding the ALSA UCM reset to 100%
- Disables `pause-on-idle`, which prevents WirePlumber from suspending the input device when not in use (suspension can sometimes cause state loss on resume)

---

## Adjusting the default volume

Change `"audio.volume"` to any value between `0.0` (mute) and `1.0` (100%):

```nix
"audio.volume" = 0.6;  # 60%
```

Rebuild after any change: `update`

---

## NVIDIA HDMI audio detected as microphone

On systems with a discrete NVIDIA GPU, the HDMI audio controller can appear as an input device and be matched by the `~alsa_input.*` pattern — incorrectly applying volume settings to it. The config handles this with an explicit disable rule targeting `api.alsa.card.name = "~HDA NVidia*"`.

## Note on changing device IDs

ALSA card numbers (card 0, card 1…) can shift between reboots depending on which device is detected first. The rules in `configuration.nix` match by `api.alsa.card.name` (e.g. `"~HD-Audio Generic*"`) rather than by node name or card number, making them stable across reboots.

If the rules are not applying, verify your card names with:

```bash
cat /proc/asound/cards
```

Then update the `api.alsa.card.name` patterns in `configuration.nix` to match.

---

## Note on EasyEffects

EasyEffects (`services.easyeffects.enable = true` in `home.nix`) can also affect microphone input levels via its input pipeline. If EasyEffects is active, check its presets in addition to the WirePlumber rule — both layers affect the final mic level.
