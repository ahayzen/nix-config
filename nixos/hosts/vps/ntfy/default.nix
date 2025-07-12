# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.vps.ntfy = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.ntfy) {
    ahayzen.docker-compose-files = [ ./compose.ntfy.yml ];

    environment.etc = {
      "caddy/sites/ntfy.Caddyfile".source = ./ntfy.Caddyfile;
    };

    # Take a snapshot of the database daily
    systemd = {
      services."ntfy-db-snapshot" = {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''
          /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/ntfy
          /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/ntfy/auth.db ".backup /var/lib/docker-compose-runner/ntfy/auth-snapshot-$(date +%w).db"
        '';
      };

      timers."ntfy-db-snapshot" = {
        enable = !config.ahayzen.testing;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "22:15";
          Unit = "ntfy-db-snapshot.service";
          Persistent = true;
        };
      };

      services."docker-compose-runner".restartTriggers = [
        (builtins.hashFile "sha256" config.environment.etc."caddy/sites/ntfy.Caddyfile".source)
      ];
    };
  };
}
