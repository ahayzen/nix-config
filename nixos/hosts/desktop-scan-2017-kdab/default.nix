# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-gpu-intel-gpu-only
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
  ];

  ahayzen = {
    hostName = "scan-2017-kdab";
  };

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 10 * 1024;
  virtualisation.vmVariant.virtualisation.memorySize = 2 * 1024;
}
