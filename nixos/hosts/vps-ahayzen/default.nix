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

  # https://github.com/rapiz1/rathole instead of SSH?
  ahayzen.docker-compose-file = "/srv/config/docker-compose-custom.yml";
}
