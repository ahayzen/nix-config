# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  # Use BindFS to map ids of users
  system.fsPackages = [ pkgs.bindfs ];

  systemd = {
    # Use systemd mount rather than filesystem as those disappear in tests
    mounts = [{
      type = "fuse.bindfs";
      mountConfig = {
        Options = "map=unpriv/unpriv-user1000:@unpriv/@unpriv-user1000";
      };
      what = "/var/lib/docker-compose-runner";
      where = "/var/lib/docker-compose-runner-user1000";
      wantedBy = [ "multi-user.target" ];
    }];

    # Ensure that docker starts after us
    services."docker-compose-runner".after = [ "var-lib-docker-compose-runner-user1000.mount" ];
  };

  # Ensure target folder exists
  system.activationScripts.mkdirDockerComposeRunnerUser1000 = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/docker-compose-runner-user1000
  '';
}
