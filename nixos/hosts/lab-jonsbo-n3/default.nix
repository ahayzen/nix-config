# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware.nix
    # Mergerfs and SnapRAID
    ./mergerfs.nix
    ./snapraid.nix
  ];

  ahayzen = {
    hostName = "lab-jonsbo-n3";
  };

  # Seed host keys for places we SSH to
  services.openssh.knownHosts = {
    "ahayzen.com".publicKey = config.ahayzen.publicKeys.host.vps;
  };

  # Enable thermal control as this is an intel laptop
  services.thermald.enable = true;

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 2 * 1024;
}
