# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware.nix
    # Bindfs, Mergerfs, and SnapRAID
    ./bindfs.nix
    ./mergerfs.nix
    ./snapraid.nix
    # Services
    ./jellyfin
    ./rathole
  ];

  ahayzen = {
    docker-compose-files = [ ./compose.lab-jonsbo-n3.yml ];
    hostName = "lab-jonsbo-n3";
  };

  # Seed host keys for places we SSH to
  services.openssh.knownHosts = {
    "ahayzen.com".publicKey = config.ahayzen.publicKeys.host.vps;
  };

  # Enable thermal control as this is an intel laptop
  services.thermald.enable = true;

  # Emulate data folders for testing
  system.activationScripts = lib.mkIf (config.ahayzen.testing) {
    mkdirMntFolders = ''
      mkdir -p /mnt/pool/backup
      chown unpriv:unpriv /mnt/pool/backup
      chmod 0755 /mnt/pool/backup

      mkdir -p /mnt/pool/cache
      chown unpriv:unpriv /mnt/pool/cache
      chmod 0755 /mnt/pool/cache

      mkdir -p /mnt/pool/data
      chown unpriv:unpriv /mnt/pool/data
      chmod 0755 /mnt/pool/data
    '';
  };

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 2 * 1024;
}
