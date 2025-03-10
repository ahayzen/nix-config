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
        what = "/mnt/disk*";
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
}
