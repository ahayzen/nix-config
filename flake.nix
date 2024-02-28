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
      mkHost = { developer ? false, games ? false, headless, hostname, platform ? "x86_64-linux" }: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit developer games headless hostname inputs outputs platform stateVersion; };

        modules = [
          # Load secrets
          ./secrets
          # Load the Agenix module
          inputs.agenix.nixosModules.default
        ];
      };

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.11";
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # Servers
        vps-ahayzen = mkHost { developer = false; games = false; headless = true; hostname = "vps-ahayzen"; };
      };
    };
}
