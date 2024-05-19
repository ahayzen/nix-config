# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    ./hardware.nix
  ];

  # OVH uses BIOS so we need to disable systemd-boot and use grub
  #
  # But we still allow for potentially using EFI boot in the future
  boot.loader = {
    # We need to disable so that efiInstallAsRemovable can be enabled
    # and we don't have an EFI mountpoint so install in the root
    efi = {
      canTouchEfiVariables = lib.mkForce false;
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

  ahayzen = {
    # Specify the docker file we are using
    docker-compose-file = ./docker-compose.yml;

    hostName = "vps";
  };

  # Config files for caddy and wagtail
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    local-py_ahayzen-com = {
      file = ../../../secrets/local-py_ahayzen-com.age;
      # do not symlink otherwise docker cannot read the file
      symlink = false;
    };
    local-py_yumekasaito-com = {
      file = ../../../secrets/local-py_yumekasaito-com.age;
      # do not symlink otherwise docker cannot read the file
      symlink = false;
    };
  };

  environment.etc = {
    "ahayzen.com/local.1.py".source =
      if config.ahayzen.testing
      then ./local.vm.py
      else config.age.secrets.local-py_ahayzen-com.path;
    "yumekasaito.com/local.1.py".source =
      if config.ahayzen.testing
      then ./local.vm.py
      else config.age.secrets.local-py_yumekasaito-com.path;
    "caddy/Caddyfile.1".source =
      if config.ahayzen.testing
      then ./Caddyfile.vm
      else ./Caddyfile;
  };

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 2 * 1024;

  # Create a tunneller user for SSH tunnels
  #
  # TODO: investigate using something like https://github.com/rapiz1/rathole
  users.users.tunneller = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [ config.ahayzen.publicKeys.user.synology-nas-tunneller ];
  };
}
