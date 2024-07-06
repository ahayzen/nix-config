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

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
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
        vps = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/vps/default.nix
            ./nixos/users/headless
          ];
        };

        # Home Lab
        lab = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/lab/default.nix
            ./nixos/users/headless
          ];
        };
      };

      checks = {
        x86_64-linux =
          let
            checkArgs = {
              lib = nixpkgs.lib;
              # reference to nixpkgs for the current system
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              inherit inputs;
              # this gives us a reference to our flake but also all flake inputs
              inherit self;
            };
          in
          {
            lab-actual-test = import ./tests/lab-actual.nix checkArgs;
            lab-bitwarden-test = import ./tests/lab-bitwarden.nix checkArgs;
            vps-wagtail-test = import ./tests/vps-wagtail.nix checkArgs;
          };
      };
    };
}
