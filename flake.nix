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

    outputs = { self, nixpkgs, home-manager, nur, ... }:
    let
        vars = import ./variables.nix;
    in {
        nixosConfigurations.${vars.hostname} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit (vars) repoPath; };
            modules = [
                { nixpkgs.overlays = [ nur.overlays.default ]; }
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.${vars.username} = import ./home.nix;
                        backupFileExtension = "backup";
                        extraSpecialArgs = { inherit (vars) repoPath; };
                    };
                }
            ];
        };
    };
}
