# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.joplin = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.joplin) {
    ahayzen.docker-compose-files = [ ./compose.joplin.yml ];

    # Take a snapshot of the database daily
    systemd = {
      services."joplin-db-snapshot" = {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/joplin/data/db.sqlite ".backup /var/lib/docker-compose-runner/joplin/data/db-snapshot-$(date +%w).sqlite"'';
      };

      timers."joplin-db-snapshot" = {
        enable = !config.ahayzen.testing;
        after = [ "nixos-upgrade.service" ];
        before = [ ]
          ++ lib.optional config.ahayzen.lab.restic "restic-offsite-backup.service"
          ++ lib.optional config.ahayzen.lab.restic "restic-local-backup.service";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Unit = "joplin-db-snapshot.service";
          Persistent = true;
        };
      };
    };
  };
}
