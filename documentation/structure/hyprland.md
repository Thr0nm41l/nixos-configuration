# config/sessions/hyprland/

Hyprland window manager session. Imported by `home.nix`. Splits configuration across several Nix modules and a large scripts directory.

---

## Nix modules

### default.nix
Main entry point for the Hyprland session. Imports all other modules in this folder and declares the session's Home Manager packages.

**Packages declared here** (Wayland/session-specific dependencies):
- Launchers & UI: `rofi-wayland`, `swww` (wallpaper), `swayosd`, `swaync`, `libnotify`
- Clipboard: `cliphist`, `wl-clipboard`
- Media: `cava`, `playerctl`, `mpris2-player-daemon`
- Screenshot/screen recording: `grim`, `slurp`, `satty`, `wl-screenrec`
- Audio: `pamixer`, `pactl` (via `pulseaudio`)
- Network/Bluetooth: `networkmanager`, `bluez` tools
- Utilities: `jq`, `imagemagick`, `socat`, `python3`, `swayidle`
- Wayland compatibility: `qt6.qtwayland`, `xwayland`

**Hyprland settings:**
- General: 8px gaps (in/out), 2px border, 10px corner radius
- Input: French keyboard (`kb_layout = "fr"`), natural scroll, flat acceleration
- Environment: `NIXOS_OZONE_WL=1` for Electron apps

### binds.nix
All keyboard and mouse bindings. See `documentation/structure/scripts.md` for details on what each bound script does.

| Category | Key | Action |
|---|---|---|
| Apps | `Super+Return` | Kitty terminal |
| Apps | `Super+F` | Firefox |
| Apps | `Super+E` | Nautilus file manager |
| Apps | `Super+T` | Telegram |
| Apps | `Super+D` | Discord |
| Apps | `Super+O` | Obsidian |
| Launcher | `Super+Space` | Rofi drun |
| Launcher | `Alt+Tab` | Rofi window switcher |
| Clipboard | `Super+V` | Rofi clipboard history |
| Widgets | `Super+Shift+S` | Stewart widget |
| Widgets | `Super+M` | Music player widget |
| Widgets | `Super+B` | Battery widget |
| Widgets | `Super+W` | Wallpaper picker |
| Widgets | `Super+S` | Monitors widget |
| Widgets | `Super+N` | Network widget |
| Widgets | `Super+Shift+T` | Focus timer widget |
| Widgets | `Super+H` | Guide/help widget |
| Widgets | `Super+A` | Swaync notification center |
| Window | `Super+Q` | Kill active window |
| Window | `Super+Shift+F` | Toggle floating |
| Window | `Super+arrows` | Move focus |
| Window | `Super+Ctrl+arrows` | Move window |
| Window | `Super+Shift+arrows` | Resize window |
| Workspaces | `Super+&` (`1`) | Switch to workspace 1 |
| Workspaces | `Super+é` … `Super+à` | Switch to workspaces 2–10 (AZERTY) |
| Workspaces | `Super+Shift+&` … | Move window to workspace 1–10 |
| Media | `Super+P` | Play/pause |
| Media | `XF86AudioPlay/Pause` | Play/pause |
| Media | `XF86AudioLower/RaiseVolume` | Volume (via swayosd) |
| Media | `xf86AudioMicMute` | Mic mute (via swayosd) |
| Media | `xf86AudioMute` | Output mute (via swayosd) |
| Media | `XF86MonBrightness*` | Brightness (via swayosd) |
| Screenshot | `Print` | Region screenshot |
| Screenshot | `Shift+Print` | Region screenshot + annotate |
| Screenshot | `Super+Print` | Full screenshot |
| Screenshot | `Super+Shift+Print` | Full screenshot + annotate |
| Lock | `Super+L` / `XF86PowerOff` | Lock screen |
| Mouse | `Super+LMB` | Move window |
| Mouse | `Super+RMB` | Resize window |

### autostart.nix
`exec-once` commands run at session start:

| Command | Purpose |
|---|---|
| `swww-daemon` | Wallpaper engine daemon |
| `swaync` | Notification center daemon |
| `hypridle` | Idle/lock timeout daemon |
| `playerctld daemon` | MPRIS player tracker |
| `wl-paste --watch cliphist store` | Clipboard history recorder |
| `settings_watcher.sh` | Watches `settings.json`, applies layout/wallpaper changes live |
| `volume_listener.sh` | Monitors PipeWire, triggers swayosd on volume changes |
| `quickshell` (Main) | Main widget overlay (workspace switcher, popups) |
| `quickshell` (TopBar) | Top status bar on each monitor |
| `focus_daemon.py` | Application usage tracker (SQLite) |

### monitors.nix
Monitor layout: single `eDP-1` display at `1920x1080@120Hz`, `0x0` position, 1× scale.

Modify this file to add external monitors or change resolution.

### hypridle.nix
Idle timeout chain:
1. After **300 s** (5 min): run `lock.sh` → shows lock screen
2. After **900 s** (15 min): `systemctl suspend`

### animations.nix
Custom animation profile:
- Bezier curve: `myBezier` (0.05, 0.9, 0.1, 1.05)
- Windows: `popin 80%` on open/close
- Layers: `fade` on open/close
- Workspaces: `slide` left/right

### window-rules.nix
Per-window behavior overrides:
- Volume/brightness OSD windows: `noanim`, `float`, `noborder`
- CS2: `immediate` rendering (disables vsync for the game window)
- App launcher (rofi): `float`, `noborder`, `noanim`

---

## Subdirectories

| Folder | Contents |
|---|---|
| `scripts/` | Bash scripts for screenshots, locking, rofi wrappers, and IPC management |
| `scripts/quickshell/` | QML widget components and their supporting scripts |

See `documentation/structure/scripts.md` and `documentation/structure/quickshell.md` for details.
