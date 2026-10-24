# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:
{
  ahayzen.docker-compose-files = [ ./compose.traefik.yml ]
    ++ lib.optional (!config.ahayzen.testing) ./compose.traefik.prod.yml;

  environment.etc = {
    # When using production enable https certs
    "traefik/traefik.prod.yml" = lib.mkIf (!config.ahayzen.testing) {
      source = ./traefik.prod.yml;
    };
  };

  # Ensure that http and https is open
  networking.firewall =
    {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };

  # Restart if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".restartTriggers = [ ] ++ lib.optional (!config.ahayzen.testing) [
    (builtins.hashFile "sha256" config.environment.etc."traefik/traefik.prod.yml".source)
  ];
}
