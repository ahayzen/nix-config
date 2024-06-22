# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  # Use SSHFS to mount folders from NAS for data and restic backups
  system.fsPackages = [ pkgs.sshfs ];
  fileSystems = lib.mkIf (!config.ahayzen.testing) {
    mntbackuprestic = {
      # TODO: can we use name?
      # https://github.com/ahayzen/nix-config/issues/141
      device = "restic@192.168.1.196:/restic/repository";
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
      # TODO: can we use name?
      # https://github.com/ahayzen/nix-config/issues/141
      device = "restic@192.168.1.196:/restic/data";
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
