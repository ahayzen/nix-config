# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.immich = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.immich) {
    ahayzen = {
      docker-compose-files = [ ./compose.immich.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t immich_postgres sh -c "pg_dumpall --clean --if-exists --username=postgres > /var/lib/docker-compose-runner/immich/postgres/immich-database.sql"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t immich_postgres sh -c "pg_dumpall --clean --if-exists --username=postgres > /var/lib/docker-compose-runner/immich/postgres/immich-database-snapshot-$(date +%w).sql"
        ''
      ];
    };

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      immich_env = {
        file = ../../../../secrets/immich_env.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    environment.etc = {
      "immich/settings.env".source = ./immich.env;
      "immich/settings_secrets.env".
      source =
        if config.ahayzen.testing
        then ./immich-secrets.vm.env
        else config.age.secrets.immich_env.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."immich/settings.env".source)
      # Agenix path with a version that can be bumped
      "/etc/immich/settings_secrets.env-1"
    ];
  };
}
