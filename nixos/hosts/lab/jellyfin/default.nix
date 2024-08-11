# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.jellyfin = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.jellyfin) {
    ahayzen = {
      docker-compose-files = [ ./compose.jellyfin.yml ];
    };

    # Ensure Jellyfin port and autodiscovery port is open
    networking.firewall.allowedTCPPorts = [
      7359
      8096
    ];
  };
}
