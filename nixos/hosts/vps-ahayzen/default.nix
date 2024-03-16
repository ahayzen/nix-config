# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    ./hardware.nix
  ];

  # OVH uses BIOS (?) so we need to disable systemd-boot and use grub
  #
  # But we still allow for potentially using EFI boot in the future
  boot.loader = {
    # We need to disable so that efiInstallAsRemovable can be enabled
    # and we don't have an EFI mountpoint so install in the root
    efi = {
      canTouchEfiVariables = lib.mkForce false;
      efiSysMountPoint = lib.mkForce "/boot";
    };

    grub = {
      enable = true;
      configurationLimit = 10;
      # disko automatically adds devices that have a EF02 partition
      # devices = [ "/dev/sda" ];
      efiSupport = true;
      # We need to enable this as we are currently booted in BIOS
      efiInstallAsRemovable = true;
      splashImage = null;
    };
    systemd-boot.enable = lib.mkForce false;
  };

  # Specify the docker file we are using
  ahayzen.docker-compose-file = ./docker-compose.yml;

  # Config files for caddy and wagtail
  age.secrets.local-py_ahayzen-com.file = ../../../secrets/local-py_ahayzen-com.age;
  environment.etc = {
    "ahayzen.com/local.1.py".source =
      if builtins.pathExists config.age.secrets.local-py_ahayzen-com.path
      then config.age.secrets.local-py_ahayzen-com.path
      else ./fallback.local.py;
    "caddy/Caddyfile.1".source = ./Caddyfile;
  };

  # Create a tunneller user for SSH tunnels
  #
  # TODO: investigate using something like https://github.com/rapiz1/rathole
  users.users.tunneller = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = config.ahayzen.publicKeys.users-openssh-vps-tunneller-authorized;
  };
}
