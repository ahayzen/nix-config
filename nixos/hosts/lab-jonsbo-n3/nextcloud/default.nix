# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.nextcloud = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.nextcloud) {
    ahayzen.docker-compose-files = [ ./compose.nextcloud.yml ];

    environment.etc = {
      "nextcloud/custom.config.php" = {
        group = "unpriv";
        mode = "0644";
        source = ./custom.config.php;
        user = "unpriv";
      };
      "nextcloud/custom.ini".source = ./custom.ini;
    };

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to mergerfs
    systemd.services."docker-compose-runner-pre-init-nextcloud" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = [
          # Configuration
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/nextcloud/html"
          # PHP temp directory
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/app/nextcloud/tmp"
          # User data
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/app/nextcloud/data/andrew"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/app/nextcloud/data/yumeka"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/user/andrew"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/user/yumeka"
          # Shared mounts
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/camera"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/files"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/movies"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/music"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/recordings"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/shows"
        ];
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # Take a snapshot of the database daily
    systemd.services."nextcloud-db-snapshot" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/nextcloud/html/data
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/nextcloud/html/data/owncloud.db ".backup /var/lib/docker-compose-runner/nextcloud/html/data/owncloud-snapshot-$(date +%w).db"
      '';
    };

    # TODO: periodically scan files
    # docker exec -u www-data nextcloud-app php occ files:scan --all

    systemd.timers."nextcloud-db-snapshot" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:15";
        Unit = "nextcloud-db-snapshot.service";
        Persistent = true;
      };
    };
  };
}
