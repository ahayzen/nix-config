# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:
{
  ahayzen.docker-compose-files = [ ./compose.acme-dns.yml ];

  environment.etc = {
    "acme-dns/config/config.cfg".source = ./acme-dns.cfg;
    "caddy/sites/acme-dns.Caddyfile".source = ./acme-dns.Caddyfile;
  };

  # Ensure that dns is open
  networking.firewall =
    {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

  # Restart if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".restartTriggers = [
    (builtins.hashFile "sha256" config.environment.etc."caddy/sites/acme-dns.Caddyfile".source)
  ];
}
