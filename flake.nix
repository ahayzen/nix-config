# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  description = "ahayzen's NixOS Configuration";

  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      url = "github:ryantm/agenix";
    };

    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs =
    { self
    , nixpkgs
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'

      # Create nixos modules which are then used by nixconfiguration and by tests
      nixosModules = {
        headlessSystem = {
          imports = [
            # Load secrets
            ./secrets
            # Load the Agenix module
            inputs.agenix.nixosModules.default
            # Load the disko module
            inputs.disko.nixosModules.disko
            # Load our common configuration
            ./nixos/modules/all
            # Load our headless configuration
            ./nixos/modules/headless
          ];
        };

        desktopSystem = {
          imports = [
            # Load secrets
            ./secrets
            # Load the Agenix module
            inputs.agenix.nixosModules.default
            # Load the disko module
            inputs.disko.nixosModules.disko
            # Load our common configuration
            ./nixos/modules/all
            # Load our desktop configuration
            ./nixos/modules/desktop
          ];
        };
      };

      nixosConfigurations = {
        # Servers
        vps-ahayzen = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/vps-ahayzen/default.nix
            ./nixos/users/headless
          ];
        };
      };
    };
}
