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

  # Ensure that paths are mounted
  systemd.services."docker-compose-runner".unitConfig = {
    RequiresMountsFor = "/mnt/backup-restic /mnt/data";
  };

  # Emulate sshfs mount folders for testing
  systemd.tmpfiles.settings = lib.mkIf (config.ahayzen.testing) {
    "99-sshfs-mount" = {
      "/mnt/backup-restic" = {
        d = {
          age = "-";
          group = "unpriv";
          mode = "0750";
          user = "unpriv";
        };
      };
      "/mnt/data" = {
        d = {
          age = "-";
          group = "unpriv";
          mode = "0750";
          user = "unpriv";
        };
      };
    };
  };
}
