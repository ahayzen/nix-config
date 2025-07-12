# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.vps.gotify = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.gotify) {
    ahayzen.docker-compose-files = [ ./compose.gotify.yml ];

    environment.etc = {
      "caddy/sites/gotify.Caddyfile".source = ./gotify.Caddyfile;
    };

    # Take a snapshot of the database daily
    systemd = {
      services."gotify-db-snapshot" = {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/gotify/db/gotify.db ".backup /var/lib/docker-compose-runner/gotify/data/gotify-snapshot-$(date +%w).db"'';
      };

      timers."gotify-db-snapshot" = {
        enable = !config.ahayzen.testing;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "22:15";
          Unit = "gotify-db-snapshot.service";
          Persistent = true;
        };
      };
    };
  };
}
