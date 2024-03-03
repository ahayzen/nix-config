# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ inputs, lib, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    ./hardware.nix
  ];

  # OVH uses BIOS (?) so we need to disable systemd-boot and use grub
  boot.loader = {
    grub = {
      enable = true;
      configurationLimit = 10;
      # disko automatically adds devices that have a EF02 partition
      # devices = [ "/dev/sda" ];
      efiSupport = false; # TODO: can OVH use EFI?
      splashImage = null;
    };
    systemd-boot.enable = lib.mkForce false;
  };

  # Specify the docker file we are using
  ahayzen.docker-compose-file = ./docker-compose.yml;
  environment.etc = {
    "caddy/Caddyfile".source = ./Caddyfile;
  };

  # Create a tunneller user for SSH tunnels
  #
  # TODO: investigate using something like https://github.com/rapiz1/rathole
  users.users.tunneller = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;

    openssh.authorizedKeys.keys = config.ahayzen.publicKeys.user__synology-nas__tunneller;
  };
}
