# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }: {
  options.ahayzen.hostName = lib.mkOption {
    type = lib.types.str;
  };

  config = {
    services = {
      # Enable avahi for discovery of .local domains
      avahi = {
        enable = true;
        nssmdns4 = true;

        publish = {
          enable = true;
          addresses = true;
          domain = true;
        };
      };
    };

    # Define the hostname of the device
    networking.hostName = config.ahayzen.hostName;
  };
}
