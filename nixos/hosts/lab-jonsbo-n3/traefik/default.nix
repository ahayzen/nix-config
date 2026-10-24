# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:
{
  ahayzen.docker-compose-files = [ ./compose.traefik.yml ]
    ++ lib.optional (!config.ahayzen.testing) ./compose.traefik.prod.yml;

  # Ensure that http and https is open
  networking.firewall =
    {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };
}
