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

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to sshfs
    systemd.services."docker-compose-runner-pre-init-joplin" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = [
          # Database folder
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/joplin/data"
        ];
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # Take a snapshot of the database daily
    systemd.services."joplin-db-snapshot" = {
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/joplin/data/db.sqlite ".backup /var/lib/docker-compose-runner/joplin/data/db-snapshot-$(date +%w).sqlite"'';
    };

    systemd.timers."joplin-db-snapshot" = {
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
}
