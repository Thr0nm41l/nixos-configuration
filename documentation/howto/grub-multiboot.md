# GRUB Multiboot Setup

## Current configuration

The bootloader is configured in `configuration.nix`:

```nix
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.grub = {
  enable = true;
  device = "nodev";       # EFI system, no MBR
  efiSupport = true;      # Install GRUB as EFI application
  useOSProber = true;     # Auto-detect other OSes
};
```

---

## How os-prober works

After each `nixos-rebuild switch`, GRUB runs `os-prober` to scan all mounted and detectable partitions for other operating systems. Any found OS (Windows, Ubuntu, etc.) is automatically added to the GRUB menu.

---

## If os-prober does not detect your other OS

### Check that os-prober finds it manually

```bash
sudo os-prober
```

Expected output (example for Windows):
```
/dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi
```

If nothing is returned, the partition is not visible to os-prober. Common causes:

**The partition is not mounted:**
Some EFI partitions are not automatically mounted. Find the Windows EFI partition:
```bash
lsblk -f
```
Look for a FAT32 partition (typically 100–500 MB). Mount it temporarily:
```bash
sudo mkdir -p /mnt/windows-efi
sudo mount /dev/nvme0n1p1 /mnt/windows-efi
sudo os-prober
```
Then rebuild: `update`

**Fast Boot is enabled in Windows:**
Windows Fast Boot prevents a clean unmount, which can make the partition undetectable. Disable it in Windows:
`Control Panel → Power Options → Choose what the power buttons do → Turn off fast startup`

**Secure Boot is interfering:**
If Secure Boot is enabled in your BIOS, GRUB may not be able to chainload the Windows bootloader. Disable Secure Boot in BIOS settings.

---

## Manual entry (fallback if os-prober keeps failing)

If os-prober reliably fails to detect your OS, add a manual entry in `configuration.nix`:

```nix
boot.loader.grub = {
  enable = true;
  device = "nodev";
  efiSupport = true;
  useOSProber = true;
  extraEntries = ''
    menuentry "Windows" {
      insmod part_gpt
      insmod fat
      insmod search_fs_uuid
      insmod chain
      search --fs-uuid --set=root <uuid-of-windows-efi-partition>
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
};
```

To find the UUID of the Windows EFI partition:
```bash
lsblk -o NAME,FSTYPE,UUID,MOUNTPOINT | grep -i fat
```

Replace `<uuid-of-windows-efi-partition>` with the UUID from the output, then rebuild: `update`

---

## Useful GRUB commands

| Task | Command |
|---|---|
| List detected OSes | `sudo os-prober` |
| List partitions with UUIDs | `lsblk -o NAME,FSTYPE,UUID,MOUNTPOINT` |
| Rebuild and update GRUB | `update` |
| Open GRUB config (generated) | `cat /boot/grub/grub.cfg` |
