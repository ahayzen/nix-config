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

    networking.firewall = {
      # Ensure Jellyfin port is open
      allowedTCPPorts = [ 8096 ];
      # Ensure Jellyfin autodiscovery port is open
      allowedUDPPorts = [ 7359 ];
    };
  };
}
