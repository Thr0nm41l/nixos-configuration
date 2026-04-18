# Fix: Battery Percentage Always Shows 0%

If the battery widget displays 0% at all times, the sysfs path used by the battery watcher scripts may not be resolving correctly on your machine.

## Affected files

- `config/sessions/hyprland/scripts/quickshell/watchers/battery_fetch.sh`

## Diagnosis

Check whether your machine exposes battery info at the expected path:

```bash
cat /sys/class/power_supply/BAT*/capacity
```

If this returns `0` or nothing, try:

```bash
acpi -b
```

If `acpi -b` returns the correct percentage, apply the fix below.

## Fix

Replace the `get_battery_percent` and `get_battery_status` functions in `battery_fetch.sh` with `acpi`-based equivalents:

**Before:**
```bash
get_battery_percent() { cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo "100"; }
get_battery_status() { cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1 || echo "Full"; }
```

**After:**
```bash
get_battery_percent() { acpi -b 2>/dev/null | grep -oP '\d+(?=%)' | head -n1 || echo "100"; }
get_battery_status() { acpi -b 2>/dev/null | grep -oP '(?<=Battery \d: )\w+' | head -n1 || echo "Full"; }
```

Make sure `acpi` is available — add it to `home.packages` in `home.nix` if needed:

```nix
home.packages = with pkgs; [
  acpi
  # ...
];
```
