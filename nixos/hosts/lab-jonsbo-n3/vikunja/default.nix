# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.vikunja = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.vikunja) {
    ahayzen.docker-compose-files = [ ./compose.vikunja.yml ];

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      immich_env = {
        file = ../../../../secrets/vikunja_env.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    environment.etc = {
      "vikunja/settings_secrets.env".
      source =
        if config.ahayzen.testing
        then ./vikunja_secrets.vm.env
        else config.age.secrets.vikunja_env.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      # Agenix path with a version that can be bumped
      "/etc/vikunja/settings_secrets.env-1"
    ];

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to mergerfs
    systemd.services."docker-compose-runner-pre-init-vikunja" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = [
          # Sftpgo itself
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/app/vikunja/files"
          # Database folder
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/vikunja/db"
        ];
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # Take a snapshot of the database daily
    systemd.services."vikunja-db-snapshot" = {
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/vikunja/db/vikunja.db ".backup /var/lib/docker-compose-runner/vikunja/db/vikunja-snapshot-$(date +%w).db"'';
    };

    systemd.timers."vikunja-db-snapshot" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:15";
        Unit = "vikunja-db-snapshot.service";
        Persistent = true;
      };
    };
  };
}
