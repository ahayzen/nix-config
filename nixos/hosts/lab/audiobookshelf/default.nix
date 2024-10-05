# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.audiobookshelf = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.audiobookshelf) {
    ahayzen.docker-compose-files = [ ./compose.audiobookshelf.yml ];

    # Take a snapshot of the database daily
    systemd = {
      services."audiobookshelf-db-snapshot" = {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/audiobookshelf/config/absdatabase.sqlite ".backup /var/lib/docker-compose-runner/audiobookshelf/config/absdatabase-snapshot-$(date +%w).sqlite"'';
      };

      timers."audiobookshelf-db-snapshot" = {
        enable = !config.ahayzen.testing;
        after = [ "nixos-upgrade.service" ];
        before = [ ]
          ++ lib.optional config.ahayzen.lab.restic "restic-offsite-backup.service"
          ++ lib.optional config.ahayzen.lab.restic "restic-local-backup.service";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Unit = "audiobookshelf-db-snapshot.service";
          Persistent = true;
        };
      };
    };
  };
}
