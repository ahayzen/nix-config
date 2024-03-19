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

      # Helper method for building hosts
      mkHost = {}: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };

        modules = [
          # Load secrets
          ./secrets
          # Load the Agenix module
          inputs.agenix.nixosModules.default
          # Load the disko module
          inputs.disko.nixosModules.disko
          # Load our root configuration
          ./nixos/modules/all
          # Load our headless configuration
          ./nixos/modules/headless
          # Load our vps-ahayzen
          ./nixos/hosts/vps-ahayzen
          # Load our headless user
          ./nixos/users/headless
        ];
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # Servers
        vps-ahayzen = mkHost { };
      };
    };
}
