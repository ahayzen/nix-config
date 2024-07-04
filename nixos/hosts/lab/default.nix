# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel-sandy-bridge
    ./hardware.nix
    ./backup.nix
    ./periodic.nix
    ./sshfs.nix
    # Include services
    ./bitwarden
  ];

  # System76 Pangolin Performance uses BIOS so we need to disable systemd-boot and use grub
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
    docker-compose-files = [ ./docker-compose.yml ];

    hostName = "lab";
  };

  # Config files for caddy and wagtail
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    rathole_toml = {
      file = ../../../secrets/rathole_toml.age;
      # Set correct owner otherwise docker cannot read the file
      #
      # Note rathole uses ID 1000 inside the container
      mode = "0666";
      owner = "unpriv";
      group = "unpriv";
    };
  };

  environment.etc = {
    "rathole/config.1.toml".
    source =
      if config.ahayzen.testing
      then ./rathole.vm.toml
      else config.age.secrets.rathole_toml.path;
  };

  # Seed host keys for places we SSH to
  services.openssh.knownHosts = {
    "diskstation.local".publicKey = config.ahayzen.publicKeys.host.diskstation;
    "ahayzen.com".publicKey = config.ahayzen.publicKeys.host.vps;
  };

  # Enable thermal control as this is an intel laptop
  services.thermald.enable = true;

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 2 * 1024;
}
