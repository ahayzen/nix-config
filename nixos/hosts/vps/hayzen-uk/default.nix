# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:
{
  ahayzen.docker-compose-files = [ ./compose.hayzen-uk.yml ];

  environment.etc = {
    "caddy/sites/hayzen-uk.Caddyfile".source = ./hayzen-uk.Caddyfile;
    "hayzen-uk/index.html".source = ./index.html;
  };

  # Reload if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".reloadTriggers = [
    (builtins.hashFile "sha256" config.environment.etc."caddy/sites/hayzen-uk.Caddyfile".source)
    (builtins.hashFile "sha256" config.environment.etc."hayzen-uk/index.html".source)
  ];
}
