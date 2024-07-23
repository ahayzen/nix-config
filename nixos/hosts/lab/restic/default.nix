# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.restic = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.restic) {
    ahayzen = {
      docker-compose-files = [ ./compose.restic-local.yml ];

      # Take a snapshot of the data daily (do not scan as this is providing estimates)
      # Keep daily snapshots for the last week, weekly for the last month, monthly for the last year, and yearly for the last 5 years
      # Prune unused data
      periodic-daily-commands = [
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic backup --host restic-local --no-scan /mnt/data"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic forget --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 5y"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic prune"
        ''
      ];

      # Check 5% of the local data weekly, so all data should be checked in around 20 weeks
      periodic-weekly-commands = [
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic check --read-data-subset=5%"
        ''
      ];
    };

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      restic_password = {
        file = ../../../../secrets/restic_password.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    environment.etc = {
      "restic/password".source =
        if config.ahayzen.testing
        then ./password.vm
        else config.age.secrets.restic_password.path;
    };
  };
}
