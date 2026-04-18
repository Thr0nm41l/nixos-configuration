# Flake Implementation

## Context

The rice had no flake and no NUR overlay configured, yet `config/programs/firefox/default.nix` referenced `pkgs.nur.repos.rycee.firefox-addons` for the Firefox extensions (Proton Pass, Proton VPN, uBlock Origin). This meant the config would fail to build without NUR being available. Implementing a flake was therefore required, not optional.

---

## Problem

`pkgs.nur` does not exist without the NUR overlay being registered. The traditional channel-based setup (`<home-manager/nixos>`) provides no mechanism to bring in NUR automatically. A flake solves both issues at once: it pins exact versions of all inputs and registers the NUR overlay cleanly.

---

## Changes made

### flake.nix (new file)

Created at the repo root. Declares three inputs:

| Input | Pinned to |
|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-25.11` |
| `home-manager` | `github:nix-community/home-manager/release-25.11` |
| `nur` | `github:nix-community/NUR` |

Defines a single NixOS configuration named `nixosbtw` (matching `variables.nix`) for `x86_64-linux`. The NUR overlay is injected via `{ nixpkgs.overlays = [ nur.overlays.default ]; }`. Home Manager is brought in as a NixOS module with `useGlobalPkgs`, `useUserPackages`, and `backupFileExtension` set here rather than in `configuration.nix`.

### configuration.nix

- Removed `<home-manager/nixos>` from the imports list — home-manager is now provided by the flake as a NixOS module.
- Removed `home-manager.backupFileExtension`, `home-manager.useGlobalPkgs`, `home-manager.useUserPackages`, and `home-manager.users.*` — these settings moved into the flake.

### config/programs/zsh/default.nix

- `update` alias changed from `sudo nixos-rebuild switch` to `sudo nixos-rebuild switch --flake /etc/nixos#nixosbtw`.

---

## First-time setup

```bash
nix flake update        # generates flake.lock
sudo nixos-rebuild switch --flake .#nixosbtw
```

Commit `flake.lock` to the repo — it pins the exact revisions used and ensures reproducible builds.

---

## Ongoing usage

| Task | Command |
|---|---|
| Rebuild | `update` alias (or `sudo nixos-rebuild switch --flake /etc/nixos#nixosbtw`) |
| Update all inputs | `nix flake update` then rebuild |
| Update one input | `nix flake update nixpkgs` then rebuild |
