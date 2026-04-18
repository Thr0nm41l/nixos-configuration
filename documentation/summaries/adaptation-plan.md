# Adaptation Plan — Forked Rice to Personal Hardware

## Context

The forked rice (`ilyamiro/nixos-configuration`) was built for an AMD CPU + NVIDIA GPU machine.
The target machine is the user's personal Intel CPU + NVIDIA GPU laptop.
The `__old_config` folder contains the user's previous working NixOS configuration, used as reference.

---

## 1. Hardware adaptation

The `hardware-configuration.nix` at the repo root belongs to the original fork author (AMD machine) and must be replaced.

**Actions:**
- Replace root `hardware-configuration.nix` with the one from `__old_config/hardware-configuration.nix`
- In `configuration.nix`: change `amdgpuBusId = "PCI:4:0:0"` to `intelBusId = "PCI:0:2:0"` in the NVIDIA PRIME block
- In `configuration.nix`: change kernel param `amd_pstate=active` to `intel_pstate=active`
- In `configuration.nix`: remove `hardware.cpu.amd.updateMicrocode = true` — the hardware config already handles this via `lib.mkDefault`
- In `configuration.nix`: consider pinning `boot.kernelPackages = pkgs.linuxPackages_6_12` — the old config used this because newer kernels broke the NVIDIA driver; verify before switching to `linuxPackages_latest`

---

## 2. Localization

The goal explicitly requires keeping the old config's localization.

**Actions (all in `configuration.nix`):**
- `time.timeZone`: `"Europe/Copenhagen"` → `"Europe/Paris"`
- `services.xserver.xkb.layout`: `"us,ru"` → `"fr"`
- Remove `kb_options = "grp:alt_shift_toggle"` from `hyprland/default.nix` input settings (only relevant for multi-layout toggle)
- Add `console.keyMap = "fr"` (present in old config, absent from fork)
- Replace all `LC_*` locale settings from `en_US.UTF-8` to `fr_FR.UTF-8`
- Add `i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" ]`
- Update keyboard layout in `config/sessions/hyprland/default.nix`: `kb_layout = "us, ru"` → `kb_layout = "fr"`
- Update workspace keybinds in `config/sessions/hyprland/binds.nix`: currently bound to US/RU number row keysyms, should use AZERTY keysyms (as in old config: `ampersand`, `eacute`, `quotedbl`, etc.)

---

## 3. Missing rice dependencies

These packages are actively used by the rice's scripts or keybinds but are not declared anywhere in the forked config.

**Actions:**
- Add `swaynotificationcenter` to `home.packages` — `swaync` is launched at startup, `swaync-client` is called by `Super+A` keybind and `matugen_reload.sh`; matugen also generates `~/.config/swaync/style.css`
- Add `hardware.bluetooth.enable = true` and `hardware.bluetooth.powerOnBoot = true` to `configuration.nix` — the bluetooth panel scripts (`bluetooth_panel_logic.sh`, `bt_fetch.sh`) use `bluetoothctl` extensively
- Add `qt6.qtwayland` to `home.packages` — required for Qt6 apps to render natively on Wayland (e.g. `qbittorrent`)
- Add `exec-once = swaync` to `config/sessions/hyprland/autostart.nix` — swaync daemon is not started on boot

---

## 4. Package cleanup — remove from forked rice

Per project good practices, packages not used by the rice should be removed.
The following are declared in the fork but serve no purpose in the rice.

| Package | Location | Reason |
|---|---|---|
| `eww` | `configuration.nix` systemPackages | Replaced by quickshell; only survives as a `/tmp` dir name |
| `papers` | `configuration.nix` systemPackages | Same purpose as `kdePackages.okular` from old config, not used by the rice — old config takes priority |
| `yq-go` | `configuration.nix` systemPackages | Not referenced in any rice script |
| `wmctrl` | `configuration.nix` systemPackages | Not referenced in any rice script |
| `gnome-shell-extensions` | `configuration.nix` systemPackages | Not needed by the rice |
| `fortune` | `hyprland/default.nix` home.packages | Declared but never called in any script |
| `alsa-utils` | `hyprland/default.nix` home.packages | Rice scripts use `pactl`/`pamixer`; `alsactl restore` was removed from autostart |
| `networkmanager_dmenu` | `hyprland/default.nix` home.packages | Not referenced in any keybind or script |
| `tree` | `hyprland/default.nix` home.packages | Not referenced in any rice script |
| `ladspaPlugins` | `hyprland/default.nix` home.packages | Not used by the rice's EasyEffects IIR equalizer |
| `ladspa-sdk` | `hyprland/default.nix` home.packages | Same as above |
| `fd` | `hyprland/default.nix` home.packages | Only used by neovim (already in `neovim/default.nix` extraPackages) |
| `ripgrep` | `hyprland/default.nix` home.packages | Only used by neovim (already in `neovim/default.nix` extraPackages) |

---

## 5. Package migration — move from configuration.nix to home.nix

Per project good practices, packages should live in `home.nix` unless system-level installation is mandatory.

| Package | Current location | Should move to |
|---|---|---|
| `inotify-tools` | `configuration.nix` systemPackages | `home.nix` or session packages |
| `killall` | `configuration.nix` systemPackages | `home.nix` or session packages |
| `matugen` | `configuration.nix` systemPackages | `home.nix` (also used by home-level scripts) |
| `ffmpeg` | `configuration.nix` systemPackages | `home.nix` |
| `kitty` | `configuration.nix` systemPackages | Already managed by `programs.kitty` in `home.nix` — remove the duplicate |
| `grim` | `configuration.nix` systemPackages | `home.nix` |
| `playerctl` | `configuration.nix` systemPackages | `home.nix` |
| `satty` | `configuration.nix` systemPackages | `home.nix` |
| `slurp` | `configuration.nix` systemPackages | `home.nix` |
| `mpvpaper` | `configuration.nix` systemPackages | `home.nix` |
| `xdg-desktop-portal-gtk` | `configuration.nix` systemPackages | Already declared via `xdg.portal.extraPortals` — remove the duplicate |

Packages that must stay in `configuration.nix`: `quickshell` (Wayland compositor-level), `power-profiles-daemon` (system service), hardware/driver related entries.

---

## 6. User packages — bring from old config

These packages were in the old config for personal use and should be added to `home.nix`.

**Add to `home.packages` in `home.nix`:**
- `discord`
- `teamspeak6-client`
- `protonmail-desktop`
- `proton-pass` (standalone app — old config had it in both home.packages and as a Firefox extension)
- `papirus-icon-theme` (and restore `gtk.iconTheme` block with `Papirus-Dark`)
- `mission-center`
- `kdePackages.okular` — old config's document viewer, not used by the rice; replaces `papers` (removed in section 4)
- `python313.withPackages (ps: with ps; [numpy pandas])` — personal python environment from old config; kept alongside the fork's python versions since python IS used by rice scripts
- `piper` (only if `services.ratbagd.enable = true` is also added to `configuration.nix`)

**Already present in the fork (no action needed):**
`obsidian`, `obs-studio`, `p7zip`, `qbittorrent`, `bottles`, `steam-run`, `pkgsCross.mingwW64.stdenv.cc`, `ffmpeg`, `matugen`

**Replaced — do not bring back:**
`waybar`, `hyprlock`, `hyprshot`, `eww`, `xfce.thunar` (nautilus is bound in the rice's `Super+E` keybind), `swappy` (satty is actively called by `screenshot.sh`)

---

## 7. Services to add

- `hardware.bluetooth.enable = true`
- `hardware.bluetooth.powerOnBoot = true`
- `services.ratbagd.enable = true` (if piper is added)
