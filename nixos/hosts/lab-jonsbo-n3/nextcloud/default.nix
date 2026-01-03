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
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/app/nextcloud/data"
          # Shared mounts
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/camera"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/documents"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/files"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/movies"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/music"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/photostream"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/recordings"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/shows"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/user"
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

    # Service to allow for triggering and nextcloud file scan
    systemd.services."nextcloud-files-scan" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files:scan --all
      '';
    };

    # Helper service to setup nextcloud apps
    systemd.services."nextcloud-setup-apps" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:enable bruteforcesettings
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:enable files_external
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:enable files_sharing

        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable activity
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable app_api
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable comments
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable contactsinteraction
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable dashboard
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable federation
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable files_downloadlimit
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable files_pdfviewer
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable files_reminders
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable files_versions
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable firstrunwizard
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable logreader
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable nextcloud_announcements
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable notifications
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable password_policy
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable privacy
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable photos
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable recommendations
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable related_resources
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable serverinfo
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable sharebymail
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable support
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable survey_client
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable systemtags
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable text
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable updatenotification
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable user_status
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable weather_status
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ app:disable webhook_listeners
      '';
    };

    # Helper service to setup external mounts
    systemd.services."nextcloud-setup-external" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        # Shared mounts
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Camera" local "null::null" --config=datadir="/mnt/pool/data/camera"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Files" local "null:null" --config=datadir="/mnt/pool/data/files"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Movies" local "null:null" --config=datadir="/mnt/pool/data/movies"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Music" local "null:null" --config=datadir="/mnt/pool/data/music"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Recordings" local "null:null" --config=datadir="/mnt/pool/data/recordings"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Shows" local "null:null" --config=datadir="/mnt/pool/data/shows"
        # Read-only mounts
        #
        # TODO: mark as read-only via files_external:option <mountid> readonly true
        # but this needs the mount id
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Documents" local "null:null" --config=datadir="/mnt/pool/data/documents"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Shared/Photostream" local "null:null" --config=datadir="/mnt/pool/data/photostream"
        # User mounts
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Personal" local "null:null" --config=datadir="/mnt/pool/data/user/andrew" --user=andrew
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -it -u 1000:1000 -t nextcloud php occ files_external:create "/Personal" local "null:null" --config=datadir="/mnt/pool/data/user/yumeka" --user=yumeka
      '';
    };

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
