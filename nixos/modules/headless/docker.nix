# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # Define the unpriv user for docker
  #
  # Set this to a high id so that we remain stable
  users = {
    groups.unpriv = {
      gid = 2000;
    };
    users.unpriv = {
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
  };

  virtualisation.docker = {
    enable = true;

    autoPrune = {
      enable = true;
      dates = "daily";
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
