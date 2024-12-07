# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
  ];

  ahayzen = {
    hostName = "laptop-thinkpad-t480-kdab";
  };

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 10 * 1024;
  virtualisation.vmVariant.virtualisation.memorySize = 2 * 1024;
}
