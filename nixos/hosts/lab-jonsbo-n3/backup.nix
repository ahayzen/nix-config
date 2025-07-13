# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  systemd = {
    services."backup-machines" = {
      script = ''
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/backup/lab/var/lib/docker-compose-runner
        /run/wrappers/bin/sudo ${pkgs.rsync}/bin/rsync --archive --checksum --delete --human-readable --ignore-times --numeric-ids --partial --progress /var/lib/docker-compose-runner/ /mnt/pool/data/backup/lab/var/lib/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/backup/vps/var/lib/docker-compose-runner
        /run/wrappers/bin/sudo ${pkgs.rsync}/bin/rsync --archive --checksum --delete --human-readable --ignore-times --numeric-ids --partial --progress --rsh="${pkgs.openssh}/bin/ssh -i /etc/ssh/ssh_host_ed25519_key -p 8022" --rsync-path="sudo rsync" headless@ahayzen.com:/var/lib/docker-compose-runner/ /mnt/pool/data/backup/vps/var/lib/docker-compose-runner
      '';
      serviceConfig = {
        ExecStopPost = lib.mkIf (!config.ahayzen.testing) [
          "/bin/sh -c 'if [ \"$$EXIT_STATUS\" == 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Title: Backup Machines\" -H \"Priority: low\" -d \"Success\" https://ntfy.hayzen.uk/lab-jonsbo-n3; fi'"
          "/bin/sh -c 'if [ \"$$EXIT_STATUS\" != 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Title: Backup Machines\" -H \"Priority: high\" -d \"Failure\" https://ntfy.hayzen.uk/lab-jonsbo-n3; fi'"
        ];
        Type = "oneshot";
      };
    };

    timers."backup-machines" = {
      # Enable when not in testing mode
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:45";
        Unit = "backup-machines.service";
        Persistent = true;
      };
    };
  };
}
