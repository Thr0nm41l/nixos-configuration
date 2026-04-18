# Changes Made — Rice Adaptation

This document records all changes applied to the fork after the adaptation plan was written.
Files in `__old_config/` were used as reference only and were never modified.

---

## hardware-configuration.nix

- Replaced the fork author's AMD hardware config with the user's Intel+NVIDIA laptop hardware config.

---

## variables.nix (new file)

- Created as a single source of truth for `username` and `hostname` (username is `"thron"` and hostname is `"nixosbtw"`).
- Imported via `let vars = import ./variables.nix;` in `configuration.nix` and `home.nix`.
- All hardcoded username/hostname references in those two files now use `vars.username` / `vars.hostname`.

---

## configuration.nix

**Hardware:**
- Replaced `amdgpuBusId = "PCI:4:0:0"` with `intelBusId = "PCI:0:2:0"` in the NVIDIA PRIME block.
- Replaced kernel param `amd_pstate=active` → `intel_pstate=active`.
- Removed `hardware.cpu.amd.updateMicrocode = true` (handled by `hardware-configuration.nix` via `lib.mkDefault`).
- Pinned kernel to `linuxPackages_6_12` (newer kernels caused instability with the NVIDIA driver on this machine).
- Added `hardware.bluetooth.enable = true` and `hardware.bluetooth.powerOnBoot = true`.
- Added `services.ratbagd.enable = true` (required for `piper` mouse configuration GUI).

**Localization:**
- `time.timeZone`: `"Europe/Copenhagen"` → `"Europe/Paris"`.
- `services.xserver.xkb.layout`: `"us,ru"` → `"fr"`.
- Added `console.keyMap = "fr"`.
- All `LC_*` locale settings changed from `en_US.UTF-8` to `fr_FR.UTF-8`.
- Added `i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" ]`.

**Package cleanup (moved to home.nix or removed):**
- Removed from `environment.systemPackages`: `eww`, `papers`, `yq-go`, `wmctrl`, `gnome-shell-extensions`, `inotify-tools`, `killall`, `matugen`, `ffmpeg`, `kitty`, `grim`, `playerctl`, `satty`, `slurp`, `mpvpaper`, `xdg-desktop-portal-gtk`.
- Remaining system packages: `quickshell`, `power-profiles-daemon`.

**Fonts:**
- Added `nerd-fonts.meslo-lg` and `nerd-fonts.jetbrains-mono`.

---

## home.nix

**Packages restructured:**
- GTK theme packages added: `adwaita-icon-theme`, `adw-gtk3`, `papirus-icon-theme`.
- Rice runtime dependencies added: `inotify-tools`, `killall`, `matugen`, `ffmpeg`, `grim`, `playerctl`, `satty`, `slurp`, `mpvpaper`.
- User packages from old config added: `wget`, `git`, `btop`, `fzf`, `direnv`, `neovim`, `python313.withPackages (numpy pandas)`, `telegram-desktop`, `libreoffice-qt`, `hunspell`, `hunspellDicts.fr-any`, `hunspellDicts.en_US`, `obsidian`, `obs-studio`, `p7zip`, `kdePackages.okular`, `fastfetch`, `jetbrains.idea-community`, `gnome-tweaks`, `pkgsCross.mingwW64.stdenv.cc`, `bottles`, `qbittorrent`, `jdk8`, `steam-run`, `discord`, `teamspeak6-client`, `protonmail-desktop`, `proton-pass`, `mission-center`, `pavucontrol`, `piper`.
- Added `qt6.qtwayland` and `swaynotificationcenter` (missing rice dependencies).

**GTK / Qt:**
- Restored `gtk.iconTheme` block with `Papirus-Dark` / `papirus-icon-theme`.
- Restored `gtk.theme` block with `adw-gtk3-dark`.

**Removed blocks (moved to dedicated modules):**
- `programs.kitty` removed — managed by `config/programs/kitty/kitty.conf` instead.
- `programs.vscode` removed — moved to `config/programs/vscode/default.nix`.
- `programs.firefox` removed — moved and consolidated into `config/programs/firefox/default.nix`.

---

## config/sessions/hyprland/default.nix

- `kb_layout`: `"us, ru"` → `"fr"`.
- Removed `kb_options` (multi-layout toggle, not needed for single layout).
- Removed unused packages: `fortune`, `alsa-utils`, `networkmanager_dmenu`, `tree`, `ladspaPlugins`, `ladspa-sdk`, `fd`, `ripgrep`, `pavucontrol` (moved to home.nix).
- Added `qt6.qtwayland` and `swaynotificationcenter`.

---

## config/sessions/hyprland/autostart.nix

- Added `"swaync"` to exec-once list (notification daemon was never started on boot).

---

## config/sessions/hyprland/binds.nix

**Workspace keybinds:** replaced US/RU number row keysyms with AZERTY equivalents:
`ampersand`, `eacute`, `quotedbl`, `apostrophe`, `parenleft`, `minus`, `egrave`, `underscore`, `ccedilla`, `agrave`.

**Keybind changes (restored from old config):**

| Bind | Before | After |
|---|---|---|
| `Super+Q` | Music widget toggle | `killactive` |
| `Super+SPACE` | `playerctl play-pause` | Rofi drun launcher |
| `Super+P` | *(unbound)* | `playerctl play-pause` |
| `Super+D` | Rofi drun launcher | Discord |
| `Super+V` | Volume widget toggle | Clipboard (rofi-clipboard) |
| `Super+M` | Monitors widget toggle | Music widget toggle |
| `Super+S` | Calendar widget toggle | Monitors widget toggle |

**Left unbound** (displaced, not restored): calendar widget, volume widget.

---

## config/programs/zsh/default.nix

- `loginctl terminate-user thron` → `loginctl terminate-user ${config.home.username}` (uses Home Manager's native value instead of hardcoded username).

---

## config/sessions/hyprland/scripts/quickshell/calendar/schedule/ (deleted)

- Entire folder removed. Contained a Danish school schedule scraper tied to the original author's school (`uddataplus.dk`).
- `CalendarPopup.qml` already has graceful degradation: checks if `schedule_manager.sh` exists at runtime before enabling the module, so deletion causes no errors.

---

## config/sessions/hyprland/scripts/quickshell/guide/GuidePopup.qml

- Removed root properties: `dotsVersion`, `remoteVersion`, `updateAvailable`.
- Removed signal handlers: `onDotsVersionChanged`, `onRemoteVersionChanged`.
- Removed `updateNotifyTimer` (fired every 15 min, sent desktop notifications about imperative-dots updates).
- Removed `versionReader` Process (read local imperative-dots version from `~/.local/state/`).
- Removed `updateChecker` Process (fetched remote version via `curl` from GitHub).
- Removed the "Update Available" button (ran `curl | bash` to install imperative-dots).
- Replaced the "Imperative v..." sidebar header with "Config Guide".
- Fixed the author attribution link: `thron/nixos-configuration` → `ilyamiro/nixos-configuration`.

---

## config/sessions/hyprland/scripts/quickshell/calendar/diary_manager.sh

- `VAULT_DIR` and `VAULT_NAME` are now read from env vars `OBSIDIAN_VAULT_DIR` / `OBSIDIAN_VAULT_NAME`, with defaults `$HOME/Documents/Obsidian` and `Obsidian`.
- New users set these in `home.sessionVariables` if their vault is elsewhere (see `documentation/howto/obsidian-diary.md`).

---

## config/programs/matugen/config.toml

- Removed `[templates.discord]` block (referenced `vesktop`, an alternative Discord client not used here).
- Updated all three Firefox profile paths: `zawmoi9h.default` → `default`.

## config/programs/matugen/templates/discord.css.template (deleted)

- Deleted. Discord custom CSS is not used.

---

## config/programs/firefox/default.nix

- Renamed profile from `zawmoi9h.default` → `default` (fixed, username-agnostic; matches matugen output paths).
- Removed `schedule.special` profile (belonged to the deleted school schedule feature).
- Absorbed extensions (`proton-pass`, `proton-vpn`, `ublock-origin`) from the old `home.nix` Firefox block.
- Updated all `chrome/` file paths from `zawmoi9h.default` → `default`.

---

## config/programs/kitty/kitty.conf

- Font changed: `JetBrains Mono` 16pt → `MesloLGS NF` 12pt.
- Background opacity: `0.85` → `0.75`.
- Background color not set: matugen's `include` at the end of the file overrides any hardcoded `background` value, so the color is driven entirely by matugen.

---

## config/programs/vscode/default.nix (new file)

- Created to hold the VSCode configuration (previously inline in `home.nix`).
- Declares four extensions: `githistory`, `rainbow-csv`, `vscode-yaml`, `nix-ide`.
- Auto-imported by `home.nix`'s directory scanner.

---

## config/fonts/JetBrainsMono/ (deleted)

- Removed the bundled JetBrains Mono TTF files — redundant with `nerd-fonts.jetbrains-mono` already declared in `configuration.nix`'s `fonts.packages`.
- `iosevka-nerd-font.ttf` kept: Iosevka is not covered by any Nix font package and is required by `GuidePopup.qml`.

---

## documentation/ (new files)

### documentation/howto/obsidian-diary.md
- Documents the `OBSIDIAN_VAULT_DIR` / `OBSIDIAN_VAULT_NAME` environment variables for configuring the calendar diary integration.

### documentation/structure/root.md
- Documents root-level files (`configuration.nix`, `home.nix`, `variables.nix`, `hardware-configuration.nix`).

### documentation/structure/programs.md
- Documents every module in `config/programs/` with per-file descriptions.

### documentation/structure/hyprland.md
- Documents the Hyprland Nix modules (`binds.nix`, `autostart.nix`, `animations.nix`, etc.) with a full keybind reference table.

### documentation/structure/scripts.md
- Documents the bash scripts in `config/sessions/hyprland/scripts/` (qs_manager, screenshot, lock, etc.).

### documentation/structure/quickshell.md
- Documents all QML widget components, their supporting scripts, and the fetch/wait watcher pattern.
