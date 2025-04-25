# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.bookstack = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.bookstack) {
    ahayzen.docker-compose-files = [ ./compose.bookstack.yml ];

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      bookstack_env = {
        file = ../../../../secrets/bookstack_env.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to mergerfs
    systemd.services."docker-compose-runner-pre-init-bookstack" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = [
          # Database folder
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/bookstack/database"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bookstack/database"
          # Config folder
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/bookstack/config"
          # Config folders we want to backup
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bookstack/backups"
          "${pkgs.coreutils}/bin/touch /var/lib/docker-compose-runner/bookstack/env"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bookstack/files"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bookstack/images"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bookstack/themes"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bookstack/uploads"
        ];
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    environment.etc = {
      "bookstack/backup.sh".source = ./backup.sh;
      "bookstack/settings.env".source = ./bookstack.env;
      "bookstack/settings_secrets.env".source =
        if config.ahayzen.testing
        then ./bookstack_secrets.vm.env
        else config.age.secrets.bookstack_env.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."bookstack/settings.env".source)
      # Agenix path with a version that can be bumped
      "/etc/bookstack/settings_secrets.env-1"
    ];

    # Take a snapshot of the database daily
    systemd.services."bookstack-db-snapshot" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      # TODO: figure out escaping to have env variables inside '' and "
      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t bookstack_database sh /usr/local/bin/bookstack-backup
      '';
      # script = ''
      #   /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t bookstack_database sh -c "mariadb-dump -u ''${MYSQL_USERNAME} bookstack > /var/lib/docker-compose-runner/bookstack/database/bookstack-database.sql"
      #   /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t bookstack_database sh -c "mariadb-dump -u bookstack bookstack > /var/lib/docker-compose-runner/bookstack/database/bookstack-database-snapshot-$(date +%w).sql"
      # '';
    };

    systemd.timers."bookstack-db-snapshot" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:15";
        Unit = "bookstack-db-snapshot.service";
        Persistent = true;
      };
    };
  };

  # TODO: use REST API to create backup using markdown/html
}

