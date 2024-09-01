# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  # Use BindFS to map ids of users
  system.fsPackages = [ pkgs.bindfs ];

  # Use systemd mount rather than filesystem as those disappear in tests
  systemd = {
    mounts = [{
      type = "fuse.bindfs";
      mountConfig = {
        Options = "map=unpriv/unpriv-user1000:@unpriv/@unpriv-user1000";
      };
      # As sshfs provides a mount this causes us to depend on it
      what = "/mnt/data";
      where = "/mnt/mapping-data-user1000";
      wantedBy = [ "multi-user.target" ];

      # Ensure that sshfs is ready
      after = lib.mkIf (!config.ahayzen.testing) [ "mnt-data.mount" ];
      requires = lib.mkIf (!config.ahayzen.testing) [ "mnt-data.mount" ];
    }];

    # Ensure that docker starts after bindfs is ready
    services."docker-compose-runner".after = [ "mnt-mapping\\x2ddata\\x2duser1000.mount" ];
    services."docker-compose-runner".requires = [ "mnt-mapping\\x2ddata\\x2duser1000.mount" ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirMappingDataUser1000 = ''
    mkdir -p /mnt/mapping-data-user1000
  '';
}
