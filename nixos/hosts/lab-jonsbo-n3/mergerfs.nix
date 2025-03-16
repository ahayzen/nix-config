# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
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
        options =
          if config.ahayzen.testing
          then "cache.files=off,category.create=mfs,dropcacheonclose=false,minfreespace=1M,fsname=mergerfspool"
          else "cache.files=off,category.create=mfs,dropcacheonclose=false,fsname=mergerfspool";
      }
    ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirMntPool = ''
    mkdir -p /mnt/pool
  '';
}
