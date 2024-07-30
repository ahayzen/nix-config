# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware.nix
    ./backup.nix
    ./bindfs.nix
    ./sshfs.nix
    # Include services
    ./actual
    ./bitwarden
    ./immich
    ./rathole
    ./restic
    ./sftpgo
  ];

  # System76 Pangolin Performance uses BIOS so we need to disable systemd-boot and use grub
  boot.loader = {
    grub = {
      enable = true;
      configurationLimit = 10;
      # disko automatically adds devices that have a EF02 partition
      # devices = [ "/dev/sda" ];
      efiSupport = lib.mkForce false;
      # We need to enable this as we are currently booted in BIOS
      splashImage = null;
    };
    systemd-boot.enable = lib.mkForce false;
  };

  ahayzen.hostName = "lab";

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
