# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:
{
  ahayzen.docker-compose-files = [ ./compose.caddy.yml ]
    ++ lib.optional config.ahayzen.testing ./compose.caddy.vm.yml;

  environment.etc = {
    "caddy/Caddyfile".source = ./Caddyfile;

    # When using a VM disable https certs
    "caddy/global/vm.Caddyfile" = lib.mkIf config.ahayzen.testing {
      source = ./global.vm.Caddyfile;
    };
  };

  # Reload if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".reloadTriggers = [
    (builtins.hashFile "sha256" config.environment.etc."caddy/Caddyfile".source)
  ];
}
