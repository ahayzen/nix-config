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

    # Take a snapshot of the database daily
    systemd.services."paperless-db-snapshot" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t paperless_webserver document_exporter --data-only --use-filename-format --zip --zip-name paperless-export-snapshot-$(date +%w)
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/paperless
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/paperless/data/db.sqlite ".backup /var/lib/docker-compose-runner/paperless/db-snapshot-$(date +%w).sqlite"
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

