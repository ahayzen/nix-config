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
        wantedBy = [ "multi-user.target" ];
        options =
          if config.ahayzen.testing
          then "cache.files=off,category.create=mfs,dropcacheonclose=false,minfreespace=1M,fsname=mergerfspool"
          else "cache.files=off,category.create=mfs,dropcacheonclose=false,fsname=mergerfspool";
      }
    ];

    # Ensure that docker starts after mergerfs is ready
    services."docker-compose-runner".after = [ "mnt-pool.mount" ];
    services."docker-compose-runner".requires = [ "mnt-pool.mount" ];

    services."docker-compose-runner-pre-init-bitwarden".after = [ "mnt-pool.mount" ];
    services."docker-compose-runner-pre-init-bitwarden".requires = [ "mnt-pool.mount" ];

    services."docker-compose-runner-pre-init-sftpgo".after = [ "mnt-pool.mount" ];
    services."docker-compose-runner-pre-init-sftpgo".requires = [ "mnt-pool.mount" ];

    services."docker-compose-runner-pre-init-vikunja".after = [ "mnt-pool.mount" ];
    services."docker-compose-runner-pre-init-vikunja".requires = [ "mnt-pool.mount" ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirMntPool = ''
    mkdir -p /mnt/pool
  '';
}
