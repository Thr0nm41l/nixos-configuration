# Window Rules for Games

Game-specific window rules are declared in `config/sessions/hyprland/window-rules.nix` under `windowrulev2`.

---

## Current rules

All Steam games (`class:^(steam_app_.*)$`) get three rules applied automatically:

| Rule | Effect |
|---|---|
| `workspace 8 silent` | Game opens on workspace 8 without pulling focus from your current workspace |
| `immediate` | Frames are presented immediately, bypassing compositor sync — reduces input latency |
| `keepaspectratio` | If the game renders at a non-native resolution, it is letterboxed/pillarboxed instead of stretched |

---

## Finding a game's window class

To add a rule for a specific game, you first need its Hyprland window class. Launch the game, then run:

```bash
hyprctl clients | grep -A5 "class:"
```

Or hover over the game window and run:

```bash
hyprctl activewindow | grep class
```

Steam games typically have a class of the form `steam_app_<appid>` (e.g. `steam_app_730` for CS2).

---

## Adding a rule for a specific game

Add an entry to the `windowrulev2` list in `window-rules.nix`:

```nix
"<rule>, class:^(<window-class>)$"
```

**Example** — disable `keepaspectratio` for a specific game that handles scaling itself:

```nix
"nokeaspectratio, class:^(steam_app_730)$"
```

Rules are evaluated top to bottom. More specific rules should be placed after the general `steam_app_.*` block so they can override it.

---

## Useful rules for games

| Rule | Use case |
|---|---|
| `immediate` | Reduce input latency (recommended for all games) |
| `keepaspectratio` | Letterbox non-native resolutions |
| `fullscreen` | Force fullscreen on launch |
| `workspace <N> silent` | Open on a specific workspace without switching to it |
| `monitor <name>` | Force game to open on a specific monitor |
| `nodim` | Prevent the window from being dimmed when unfocused |
