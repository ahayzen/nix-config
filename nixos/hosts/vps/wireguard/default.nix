# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  options.ahayzen.vps.wireguard = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.wireguard) {
    ahayzen.docker-compose-files = [ ./compose.wireguard.yml ];

    # Add the wireguard kernel module
    boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

    networking.firewall =
      {
        allowedUDPPorts = [ 51821 ];
      };
  };
}
