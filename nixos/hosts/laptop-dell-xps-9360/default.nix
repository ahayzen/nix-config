# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.dell-xps-13-9380
  ];

  ahayzen = {
    hostName = "laptop-dell-xps-9360";
  };

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 10 * 1024;
  virtualisation.vmVariant.virtualisation.memorySize = 2 * 1024;
}
