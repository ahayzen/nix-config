# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  # Use BindFS to map ids of users
  system.fsPackages = [ pkgs.bindfs ];

  systemd = {
    # Use systemd mount rather than filesystem as those disappear in tests
    mounts = [
      {
        type = "fuse.bindfs";
        mountConfig = {
          # Note .mount units are reloaded if only their Options changed.
          # which then fails for fuse bindfs filesystems as -o remount is unsupported
          # https://nixos.org/manual/nixos/stable/#sec-unit-handling
          Options = "map=unpriv/unpriv-user1000:@unpriv/@unpriv-user1000";
        };
        what = "/var/lib/docker-compose-runner";
        where = "/var/lib/docker-compose-runner-user1000";
        wantedBy = [ "multi-user.target" ];
      }
      {
        type = "fuse.bindfs";
        mountConfig = {
          # Note .mount units are reloaded if only their Options changed.
          # which then fails for fuse bindfs filesystems as -o remount is unsupported
          # https://nixos.org/manual/nixos/stable/#sec-unit-handling
          Options = "map=unpriv/unpriv-user1001:@unpriv/@unpriv-user1001";
        };
        what = "/var/lib/docker-compose-runner";
        where = "/var/lib/docker-compose-runner-user1001";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    # Ensure that docker starts after bindfs is ready
    services."docker-compose-runner".after = [ "var-lib-docker\\x2dcompose\\x2drunner\\x2duser1000.mount" "var-lib-docker\\x2dcompose\\x2drunner\\x2duser1001.mount" ];
    services."docker-compose-runner".requires = [ "var-lib-docker\\x2dcompose\\x2drunner\\x2duser1000.mount" "var-lib-docker\\x2dcompose\\x2drunner\\x2duser1001.mount" ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirDockerComposeRunnerUser1000 = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/docker-compose-runner-user1000
  '';
  system.activationScripts.mkdirDockerComposeRunnerUser1001 = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/docker-compose-runner-user1001
  '';
}
