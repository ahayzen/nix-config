# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:
{
  systemd = {
    services."backup-machines" = {
      script = ''
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/backup/lab/outdated/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/backup/lab/latest/docker-compose-runner
        /run/wrappers/bin/sudo ${pkgs.rsync}/bin/rsync --archive --backup-dir=/mnt/pool/data/backup/lab/outdated/docker-compose-runner --checksum --delete --human-readable --ignore-times --numeric-ids --partial --progress /var/lib/docker-compose-runner/ /mnt/pool/data/backup/lab/latest/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/backup/vps/outdated/docker-compose-runner
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /mnt/pool/data/backup/vps/latest/docker-compose-runner
        /run/wrappers/bin/sudo ${pkgs.rsync}/bin/rsync --archive --backup-dir=/mnt/pool/data/backup/vps/outdated/docker-compose-runner --checksum --delete --human-readable --ignore-times --numeric-ids --partial --progress --rsh="${pkgs.openssh}/bin/ssh -i /etc/ssh/ssh_host_ed25519_key -p 8022" --rsync-path="sudo rsync" headless@ahayzen.com:/var/lib/docker-compose-runner/ /mnt/pool/data/backup/vps/latest/docker-compose-runner
      '';
      serviceConfig = {
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
