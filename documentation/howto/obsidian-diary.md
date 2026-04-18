# Obsidian Diary Integration

The calendar widget includes a diary button that creates and opens a daily note in Obsidian.

## Configuration

The script (`config/sessions/hyprland/scripts/quickshell/calendar/diary_manager.sh`) reads two environment variables:

| Variable | Default | Description |
|---|---|---|
| `OBSIDIAN_VAULT_DIR` | `$HOME/Documents/Obsidian` | Absolute path to your Obsidian vault folder |
| `OBSIDIAN_VAULT_NAME` | `Obsidian` | The vault name as it appears in Obsidian (used in the `obsidian://` URI) |

Set these in your shell environment (e.g. in `home.sessionVariables` inside `home.nix`):

```nix
home.sessionVariables = {
  OBSIDIAN_VAULT_DIR = "/home/youruser/Documents/MyVault";
  OBSIDIAN_VAULT_NAME = "MyVault";
};
```

## Diary structure

The script creates notes under `<vault>/Diary/<year>/<day>.<month>.md` and maintains a `<vault>/Diary/Contents.md` index file. It then opens the note directly via the Obsidian URI protocol.
