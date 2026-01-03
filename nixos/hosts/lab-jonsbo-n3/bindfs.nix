# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bindfs
  ];

  # Use systemd mount rather than filesystem as those disappear in tests
  systemd = {
    mounts = [
      {
        type = "fuse.bindfs";
        mountConfig = {
          # Note .mount units are reloaded if only their Options changed.
          # which then fails for fuse bindfs filesystems as -o remount is unsupported
          # https://nixos.org/manual/nixos/stable/#sec-unit-handling
          Options = "map=unpriv/unpriv-user1000:@unpriv/@unpriv-user1000";
        };
        # As mergerfs provides a mount this causes us to depend on it
        what = "/mnt/pool";
        where = "/mnt/mapping-pool-user1000";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    # Ensure that docker starts after bindfs is ready
    services."docker-compose-runner".after = [
      "mnt-mapping\\x2dpool\\x2duser1000.mount"
    ];
    services."docker-compose-runner".requires = [
      "mnt-mapping\\x2dpool\\x2duser1000.mount"
    ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirMappingPoolUser1000 = ''
    mkdir -p /mnt/mapping-pool-user1000
  '';
}
