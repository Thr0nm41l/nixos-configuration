# config/sessions/hyprland/scripts/

Bash scripts providing runtime functionality for the Hyprland session. All scripts are deployed to `~/.config/hypr/scripts/` via a symlink managed in `hyprland/default.nix`.

---

## Top-level scripts

### qs_manager.sh
**Central IPC dispatcher for Quickshell widgets.**

The main bridge between Hyprland keybinds and the QML widget system.

**Usage:**
```
qs_manager.sh toggle <widget>      # toggle a named popup open/closed
qs_manager.sh <N>                  # switch to workspace N
qs_manager.sh <N> move             # move active window to workspace N
```

**Widget names:** `stewart`, `music`, `battery`, `wallpaper`, `monitors`, `network`, `focustime`, `guide`

**Internal logic:**
- Writes target widget name + command to `/tmp/qs_active_widget` and `/tmp/qs_widget_state` (QML polls these files via IPC)
- Before opening the `wallpaper` widget: pre-generates thumbnails with `ffmpeg` (video frames) and ImageMagick (image resizing) into `/tmp/qs_wallpapers/`
- Before opening the `network` widget: triggers a Bluetooth scan via `bluetooth_panel_logic.sh`

### lock.sh
Triggers the Quickshell lock screen:
```bash
quickshell -p ~/.config/hypr/scripts/quickshell/Lock.qml
```

### settings_watcher.sh
**Live settings applier.** Started at session launch via `autostart.nix`.

Watches `~/.config/hypr/settings.json` with `inotifywait`. On change, reads the JSON and applies:
- `language` → updates `kb_layout` in `hyprland.conf` via `hyprctl keyword`
- `openGuideAtStartup` → enables/disables autostart entry for the guide widget
- `wallpaperDir` → updates the wallpaper directory path in both `hyprland.conf` and `.zshrc`

### screenshot.sh
**Advanced screenshot and screen recording tool.**

**Flags:**
| Flag | Behaviour |
|---|---|
| *(none)* | Region screenshot (select area with Quickshell overlay) |
| `--edit` | Region screenshot → open in Satty for annotation |
| `--full` | Full-screen screenshot |
| `--full --edit` | Full-screen → Satty |
| `--record` | Region screen recording (wl-screenrec + optional audio) |

Screenshots are saved to `~/Pictures/Screenshots/` with a timestamp filename.
Recordings are saved to `~/Videos/Recordings/`.

**Dependencies:** `grim`, `slurp`, `satty`, `wl-screenrec`, `ffmpeg`, `wl-copy`

### rofi_show.sh
Rofi launcher toggle: kills rofi if already open, otherwise launches it in the given mode.
```
rofi_show.sh drun      # app launcher
rofi_show.sh window    # window switcher
```

### rofi_clipboard.sh
Clipboard history viewer. Pipes `cliphist list` into rofi, decodes the selected entry, and writes it back to clipboard with `wl-copy`.

### volume_listener.sh
**PipeWire volume event monitor.** Started at session launch via `autostart.nix`.

Watches `pactl subscribe` for sink/source change events. On each relevant event, calls `swayosd-client` to display the current volume level. Deduplicates rapid events to prevent OSD spam.

---

## quickshell/ subdirectory

See `documentation/structure/quickshell.md` for full details on the QML widget system and its supporting scripts.
