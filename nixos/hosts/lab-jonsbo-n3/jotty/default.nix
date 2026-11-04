# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.jotty = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.jotty) {
    ahayzen.docker-compose-files = [ ./compose.jotty.yml ];

    environment.etc = {
      "traefik/dynamic/traefik.jotty.yml".source = ./traefik.jotty.yml;
    };

    # Take a snapshot of the database daily
    systemd = {
      services."jotty-db-snapshot" = {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/jotty/db/relatons.db ".backup /var/lib/docker-compose-runner/jotty/db/relations-$(date +%w).db"'';
      };

      timers."jotty-db-snapshot" = {
        enable = !config.ahayzen.testing;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "22:15";
          Unit = "jotty-db-snapshot.service";
          Persistent = true;
        };
      };

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to mergerfs
    services."docker-compose-runner-pre-init-jotty" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = [
          # Cache folder
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/jotty/cache"
          # Database folder
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/jotty/db"
          # Config folder
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/jotty/config"
          # Data folder
          "${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/app/jotty/data"
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
      services."docker-compose-runner".restartTriggers = [
        (builtins.hashFile "sha256" config.environment.etc."traefik/dynamic/jotty.actual.yml".source)
      ];
    };
  };
}
