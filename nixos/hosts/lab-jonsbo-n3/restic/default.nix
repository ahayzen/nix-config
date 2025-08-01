# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.restic = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.restic) {
    ahayzen.docker-compose-files = [ ./compose.restic-local.yml ] ++ lib.optional (!config.ahayzen.testing) ./compose.restic-offsite.yml;

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


    # Take a snapshot of the data daily (do not scan as this is providing estimates)
    # Keep daily snapshots for the last week, weekly for the last month, monthly for the last year, and yearly for the last 5 years
    # Prune unused data
    #
    # Check 1% of the data daily, so all data should be checked 3 times a year
    #
    # Skip if nixos-upgrade is running
    # As we do not want docker / docker-compose-runner to stop
    systemd.services."restic-local-backup" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecCondition = ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nixos-upgrade.service ) != activ* ]]"'';
        ExecStopPost = lib.mkIf (!config.ahayzen.testing) [
          "/bin/sh -c 'if [ \"$$EXIT_STATUS\" == 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Tags: tada\" -H \"Title: Restic Local\" -H \"Priority: low\" -d \"Success\" https://ntfy.hayzen.uk/lab-jonsbo-n3-backup; fi'"
          "/bin/sh -c 'if [ \"$$EXIT_STATUS\" != 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Tags: warning\" -H \"Title: Restic Local\" -H \"Priority: high\" -d \"Failure\" https://ntfy.hayzen.uk/lab-jonsbo-n3-backup; fi'"
        ];
        Type = "oneshot";
      };
      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic backup --host restic-local --group-by host,tags --no-scan --retry-lock=6h --tag pool-data /mnt/pool/data"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic forget --group-by host,tags --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 5y"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic prune"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic snapshots"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic stats --mode files-by-contents"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_local /bin/sh -c "/usr/bin/restic check --read-data-subset=1% --retry-lock=6h"
      '';
    };

    systemd.services."restic-offsite-backup" = {
      requires = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecCondition = ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nixos-upgrade.service ) != activ* ]]"'';
        ExecStopPost = [
          "/bin/sh -c 'if [ \"$$EXIT_STATUS\" == 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Tags: tada\" -H \"Title: Restic Offsite\" -H \"Priority: low\" -d \"Success\" https://ntfy.hayzen.uk/lab-jonsbo-n3-backup; fi'"
          "/bin/sh -c 'if [ \"$$EXIT_STATUS\" != 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Tags: warning\" -H \"Title: Restic Offsite\" -H \"Priority: high\" -d \"Failure\" https://ntfy.hayzen.uk/lab-jonsbo-n3-backup; fi'"
        ];
        Type = "oneshot";
      };
      script = ''
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic backup --host restic-offsite --group-by host,tags --no-scan --retry-lock=6h --tag pool-data /mnt/pool/data"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic forget --group-by host,tags --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 5y"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic prune"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic snapshots"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic stats --mode files-by-contents"
        /run/wrappers/bin/sudo ${pkgs.docker}/bin/docker exec -t restic_offsite /bin/sh -c "/usr/bin/restic check --read-data-subset=1% --retry-lock=6h"
      '';
    };

    systemd.timers."restic-local-backup" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "01:30";
        Unit = "restic-local-backup.service";
        Persistent = true;
      };
    };

    systemd.timers."restic-offsite-backup" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "01:30";
        Unit = "restic-offsite-backup.service";
        Persistent = true;
      };
    };

    # Add a condition to nixos-upgrade
    # This then skips nixos-upgrade if restic is running
    # As we do not want docker / docker-compose-runner to stop

    systemd.services."nixos-upgrade" = {
      serviceConfig = {
        ExecCondition = [
          "/bin/sh -c '[[ $( ${pkgs.systemd}/bin/systemctl is-active restic-local-backup.service ) != activ* ]]'"
          "/bin/sh -c '[[ $( ${pkgs.systemd}/bin/systemctl is-active restic-offsite-backup.service ) != activ* ]]'"
        ];
      };
    };
  };
}
