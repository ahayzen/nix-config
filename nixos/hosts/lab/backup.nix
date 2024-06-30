# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  systemd = {
    services."backup-machines" = {
      script = ''
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/data/backup/lab/outdated/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/data/backup/lab/latest/docker-compose-runner
        /run/wrappers/bin/sudo ${pkgs.rsync}/bin/rsync --archive --backup-dir=/mnt/data/backup/lab/outdated/docker-compose-runner --checksum --delete --human-readable --ignore-times --numeric-ids --partial --progress /var/lib/docker-compose-runner/ /mnt/data/backup/lab/latest/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/data/backup/vps/outdated/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/data/backup/vps/latest/docker-compose-runner
        /run/wrappers/bin/sudo ${pkgs.rsync}/bin/rsync --archive --backup-dir=/mnt/data/backup/vps/outdated/docker-compose-runner --checksum --delete --human-readable --ignore-times --numeric-ids --partial --progress --rsh="${pkgs.openssh}/bin/ssh -i /etc/ssh/ssh_host_ed25519_key -p 8022" --rsync-path="sudo rsync" headless@ahayzen.com:/var/lib/docker-compose-runner/ /mnt/data/backup/vps/latest/docker-compose-runner
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    timers."backup-machines" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "backup-machines.service";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };
  };
}
