# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.paperless = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.paperless) {
    ahayzen.docker-compose-files = [ ./compose.paperless.yml ];

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      paperless_env = {
        file = ../../../../secrets/paperless_env.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    environment.etc = {
      "paperless/settings_secrets.env".
      source =
        if config.ahayzen.testing
        then ./paperless-secrets.vm.env
        else config.age.secrets.paperless_env.path;
    };

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to mergerfs
    systemd.services."docker-compose-runner-pre-init-paperless" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = [
          # Database folder
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/paperless/data"
          # Data folders
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/app/paperless/export"
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/documents"
        ];
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      # Agenix path with a version that can be bumped
      "/etc/paperless/settings_secrets.env-1"
    ];

    # Take a snapshot of the database daily
    systemd.services."paperless-db-snapshot" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t paperless_webserver document_exporter --data-only --use-filename-format --zip --zip-name paperless-export-snapshot-$(date +%w) ../export
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/paperless/data
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/paperless/data/db.sqlite3 ".backup /var/lib/docker-compose-runner/paperless/data/db-snapshot-$(date +%w).sqlite3"
      '';
    };

    systemd.timers."paperless-db-snapshot" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:15";
        Unit = "paperless-db-snapshot.service";
        Persistent = true;
      };
    };
  };
}

