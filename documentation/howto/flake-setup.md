# Setting Up the Flake

This configuration requires a flake to work correctly. The Firefox extensions (`proton-pass`, `proton-vpn`, `ublock-origin`) are sourced from [NUR](https://github.com/nix-community/NUR) via `pkgs.nur.repos.rycee.firefox-addons`. Without the NUR overlay registered as a flake input, the build will fail.

---

## 1. Create flake.nix

Create `flake.nix` at the root of the repo (next to `configuration.nix`):

```nix
{
    description = "NixOS configuration";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nur.url = "github:nix-community/NUR";
    };

    outputs = { self, nixpkgs, home-manager, nur, ... }: {
        nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                { nixpkgs.overlays = [ nur.overlays.default ]; }
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.<username> = import ./home.nix;
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
    };
}
```

Replace `<hostname>` and `<username>` with the values from `variables.nix`.

---

## 2. Update configuration.nix

The home-manager settings are now declared in the flake, so remove them from `configuration.nix`:

**Remove** this import:
```nix
<home-manager/nixos>
```

**Remove** these lines:
```nix
home-manager.backupFileExtension = "backup";
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
home-manager.users.${vars.username} = {
    imports = [ ./home.nix ];
};
```

---

## 3. Update the rebuild alias

The `update` alias in `config/programs/zsh/default.nix` currently runs:
```bash
sudo nixos-rebuild switch
```

With a flake, it must point to the flake and the configuration name. Update it to:
```nix
update = "sudo nixos-rebuild switch --flake /etc/nixos#<hostname>";
```

---

## 4. Initial build

From the repo root, generate the lock file and build:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

After the first successful build, the `update` alias works for subsequent rebuilds.

---

## Notes

- `flake.lock` pins the exact revisions of nixpkgs, home-manager, and NUR. Commit it to the repo so builds are reproducible.
- To update all inputs to their latest versions: `nix flake update` before rebuilding.
- To update a single input: `nix flake update nixpkgs`.
- The NixOS channel (`nix-channel`) is no longer used when building via flake — the `nixpkgs` input in `flake.nix` is the sole source of packages.
