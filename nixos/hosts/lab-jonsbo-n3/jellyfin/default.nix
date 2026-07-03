# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.jellyfin = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.jellyfin) {
    ahayzen = {
      docker-compose-files = [ ./compose.jellyfin.yml ];
    };

    environment.etc = {
      "traefik/dynamic/traefik.jellyfin.yml".source = ./traefik.jellyfin.yml;
    };

    networking.firewall = {
      # Ensure Jellyfin port is open
      allowedTCPPorts = [ 8096 ];
      # Ensure Jellyfin autodiscovery port is open
      allowedUDPPorts = [ 7359 ];
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."traefik/dynamic/traefik.jellyfin.yml".source)
    ];
  };
}
