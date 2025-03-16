# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  # Create pool from data disks
  systemd = {
    mounts = [
      {
        type = "fuse.mergerfs";
        what = "/mnt/data*";
        where = "/mnt/pool";
        requires = [ "local-fs.target" ];
        wantedBy = [ "multi-user.target" ];
        options = "cache.files=off,category.create=mfs,dropcacheonclose=false,fsname=mergerfspool";
      }
    ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirMntPool = ''
    mkdir -p /mnt/pool
  '';

  # Emulate data folders for testing
  system.activationScripts = lib.mkIf (config.ahayzen.testing) {
    mkdirMntFolders = ''
      mkdir -p /mnt/pool/backup
      chown unpriv:unpriv /mnt/pool/backup
      chmod 0755 /mnt/pool/backup

      mkdir -p /mnt/pool/cache
      chown unpriv:unpriv /mnt/pool/cache
      chmod 0755 /mnt/pool/cache

      mkdir -p /mnt/pool/data
      chown unpriv:unpriv /mnt/pool/data
      chmod 0755 /mnt/pool/data
    '';
  };
}
