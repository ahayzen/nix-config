# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }: {
  # Define the unpriv user for docker
  #
  # Set this to a high id so that we remain stable
  users = {
    groups = {
      unpriv = {
        gid = 2000;
      };

      # Create a group on the host that maps to gid 1000 in the unpriv subgid range
      unpriv-user33 = {
        gid = 200033;
      };
      unpriv-user1000 = {
        gid = 201000;
      };
      unpriv-user1001 = {
        gid = 201001;
      };
    };

    users = {
      unpriv = {
        isNormalUser = true;
        group = "unpriv";
        uid = 2000;

        # Map the root sub id to the same as the user (as it is unpriviledged)
        # then map the remaining uids high
        subGidRanges = [
          {
            count = 1;
            startGid = 2000;
          }
          {
            count = 65535;
            startGid = 200001;
          }
        ];
        subUidRanges = [
          {
            count = 1;
            startUid = 2000;
          }
          {
            count = 65535;
            startUid = 200001;
          }
        ];
      };

      # Create a user on the host that maps to uid 1000 in the unpriv subuid range
      unpriv-user33 = {
        isNormalUser = true;
        group = "unpriv-user33";
        uid = 200033;
      };
      unpriv-user1000 = {
        isNormalUser = true;
        group = "unpriv-user1000";
        uid = 201000;
      };
      unpriv-user1001 = {
        isNormalUser = true;
        group = "unpriv-user1001";
        uid = 201001;
      };
    };
  };

  virtualisation.docker = {
    enable = true;

    autoPrune = {
      # Enable when not in testing mode
      enable = !config.ahayzen.testing;
      dates = "13:30";
    };

    daemon.settings = {
      dns = [ "9.9.9.9" ];
      no-new-privileges = true;
      userns-remap = "unpriv:unpriv";
    };

    # rootless is too problematic as it requires services to run as user services
    # which has issues with linger on nix and the DOCKER_HOST is not set in systemd
    # rootless = {
    #   enable = true;
    #
    #   # Set DOCKER_HOST for users
    #   setSocketVariable = true;
    # };
  };
}
