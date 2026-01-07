# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  description = "ahayzen's NixOS Configuration";

  inputs = {
    agenix = {
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      url = "github:ryantm/agenix";
    };

    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix/release-25.11";
    };

    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko/latest";
    };

    folderbox = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ahayzen/folderbox";
    };

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.11";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
            # Load the catppuccin module
            inputs.catppuccin.nixosModules.catppuccin
            # Load the flatpak module
            inputs.nix-flatpak.nixosModules.nix-flatpak
            # Load home manager module
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            # Load our common configuration
            ./nixos/modules/all
            # Load our desktop configuration
            ./nixos/modules/desktop
          ];
        };
      };

      nixosConfigurations = {
        #
        # Headless systems
        #
        vps = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/vps/default.nix
            ./nixos/users/headless
          ];
        };
        vps-vm-test = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/vps/default.nix
            ./nixos/users/headless
            {
              ahayzen.testing = true;
            }
          ];
        };

        lab-jonsbo-n3 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/lab-jonsbo-n3/default.nix
            ./nixos/users/headless
          ];
        };
        lab-jonsbo-n3-vm-test = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.headlessSystem
            ./nixos/hosts/lab-jonsbo-n3/default.nix
            ./nixos/users/headless
            {
              ahayzen.testing = true;
            }
          ];
        };

        #
        # Desktop systems
        #
        desktop-scan-2017-kdab = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.desktopSystem
            ./nixos/hosts/desktop-scan-2017-kdab
            # TODO: include all users and have a config option?
            # Then move into the desktopSystem module
            ./nixos/users/andrew
            {
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
              home-manager.users.andrew = self.homeManagerModules.andrew-kdab;
            }
          ];
        };
        laptop-dell-xps-9360 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.desktopSystem
            ./nixos/hosts/laptop-dell-xps-9360
            # TODO: include all users and have a config option?
            # Then move into the desktopSystem module
            ./nixos/users/andrew
            {
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
              home-manager.users.andrew = self.homeManagerModules.andrew;
            }
          ];
        };
        laptop-thinkpad-t480-kdab = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            self.nixosModules.desktopSystem
            ./nixos/hosts/laptop-thinkpad-t480-kdab
            # TODO: include all users and have a config option?
            # Then move into the desktopSystem module
            ./nixos/users/andrew
            {
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
              home-manager.users.andrew = self.homeManagerModules.andrew-kdab;
            }
          ];
        };
      };

      homeManagerModules = {
        andrew = {
          imports = [
            ./home-manager/andrew
            # Load the catppuccin module
            inputs.catppuccin.homeManagerModules.catppuccin
          ];
        };

        andrew-kdab = {
          imports = self.homeManagerModules.andrew.imports ++ [
            {
              ahayzen.kdab = true;
            }
          ];
        };
      };

      homeConfigurations = {
        andrew = inputs.home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = { inherit inputs outputs; };

          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = self.homeManagerModules.andrew.imports;
        };
        andrew-kdab = inputs.home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = { inherit inputs outputs; };

          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = self.homeManagerModules.andrew-kdab.imports;
        };
      };

      checks = {
        x86_64-linux =
          let
            checkArgs = {
              lib = nixpkgs.lib;
              # reference to nixpkgs for the current system
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              inherit inputs outputs;
              # this gives us a reference to our flake but also all flake inputs
              inherit self;
            };
          in
          {
            desktop-test = import ./tests/desktop.nix checkArgs;
            lab-actual-test = import ./tests/lab-actual.nix checkArgs;
            lab-audiobookshelf-test = import ./tests/lab-audiobookshelf.nix checkArgs;
            lab-bitwarden-test = import ./tests/lab-bitwarden.nix checkArgs;
            lab-bookstack-test = import ./tests/lab-bookstack.nix checkArgs;
            lab-immich-test = import ./tests/lab-immich.nix checkArgs;
            lab-jellyfin-test = import ./tests/lab-jellyfin.nix checkArgs;
            lab-nextcloud-test = import ./tests/lab-nextcloud.nix checkArgs;
            lab-paperless-test = import ./tests/lab-paperless.nix checkArgs;
            lab-restic-test = import ./tests/lab-restic.nix checkArgs;
            lab-sftpgo-test = import ./tests/lab-sftpgo.nix checkArgs;
            lab-vikunja-test = import ./tests/lab-vikunja.nix checkArgs;
            vps-test = import ./tests/vps.nix checkArgs;
          };
      };
    };
}
