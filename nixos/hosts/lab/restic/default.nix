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
      docker-compose-files = [ ./compose.restic-local.yml ] ++ lib.optional (!config.ahayzen.testing) ./compose.restic-offsite.yml;

      # Take a snapshot of the data daily (do not scan as this is providing estimates)
      # Keep daily snapshots for the last week, weekly for the last month, monthly for the last year, and yearly for the last 5 years
      # Prune unused data
      periodic-daily-commands = [
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic backup --host restic-local --no-scan --quiet /mnt/data"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic forget --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 5y"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic prune"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic snapshots"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic stats --mode files-by-contents"
        ''
      ] ++ lib.optional (!config.ahayzen.testing)
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic backup --host restic-offsite --no-scan --quiet /mnt/data"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic forget --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 5y"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic prune"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic snapshots"
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic stats --mode files-by-contents"
        ''
      ;

      # Check 5% of the data weekly, so all data should be checked in around 20 weeks
      periodic-weekly-commands = [
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic check --read-data-subset=5%"
        ''
      ] ++ lib.optional (!config.ahayzen.testing)
        ''
          /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic check --read-data-subset=5%"
        ''
      ;
    };

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      restic_password = {
        file = ../../../../secrets/restic_password.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };

      restic_offsite_env = {
        file = ../../../../secrets/restic_offsite_env.age;
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
      "restic/offsite.env".source =
        if config.ahayzen.testing
        then ./offsite.env
        else config.age.secrets.restic_offsite_env.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      # Agenix path with a version that can be bumped
      "/etc/restic/password"
      "/etc/restic/offsite.env"
    ];
  };
}
