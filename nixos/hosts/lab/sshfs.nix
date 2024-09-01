# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  # Use SSHFS to mount folders from NAS for data and restic backups
  system.fsPackages = [ pkgs.sshfs ];
  fileSystems = lib.mkIf (!config.ahayzen.testing) {
    mntbackuprestic = {
      device = "restic@diskstation.local:/restic/repository";
      mountPoint = "/mnt/backup-restic";
      fsType = "sshfs";
      options =
        [
          "_netdev"

          "allow_other"

          "IdentityFile=/etc/ssh/ssh_host_ed25519_key"
          "Port=8022"

          "reconnect"
          "ServerAliveInterval=10"
          "ServerAliveCountMax=3"

          "follow_symlinks"

          "idmap=user"
          "uid=2000"
          "gid=2000"
        ];
    };
    mntdata = {
      device = "restic@diskstation.local:/restic/data";
      mountPoint = "/mnt/data";
      fsType = "sshfs";
      options =
        [
          "_netdev"

          # might need user_allow_other in fuse cofig?
          "allow_other"

          "IdentityFile=/etc/ssh/ssh_host_ed25519_key"
          "Port=8022"

          "reconnect"
          "ServerAliveInterval=10"
          "ServerAliveCountMax=3"

          "follow_symlinks"

          "idmap=user"
          "uid=2000"
          "gid=2000"
        ];
    };
  };

  # Ensure that docker starts after sshfs is ready
  systemd = lib.mkIf (!config.ahayzen.testing) {
    services."docker-compose-runner".after = [ "mnt-backup\\x2drestic.mount" "mnt-data.mount" ];
    services."docker-compose-runner".requires = [ "mnt-backup\\x2drestic.mount" "mnt-data.mount" ];
  };

  # Emulate sshfs mount folders for testing
  system.activationScripts = lib.mkIf (config.ahayzen.testing) {
    mkdirMntFolders = ''
      mkdir -p /mnt/backup-restic
      chown unpriv:unpriv /mnt/backup-restic
      chmod 0755 /mnt/backup-restic

      mkdir -p /mnt/data
      chown unpriv:unpriv /mnt/data
      chmod 0755 /mnt/data
    '';
  };
}
