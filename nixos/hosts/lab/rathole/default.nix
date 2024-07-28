# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.lab.rathole = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.rathole) {
    ahayzen.docker-compose-files = [ ./compose.rathole.yml ]
      ++ lib.optional config.ahayzen.lab.actual ./compose.rathole.actual.yml
      ++ lib.optional config.ahayzen.lab.bitwarden ./compose.rathole.bitwarden.yml
      ++ lib.optional config.ahayzen.lab.immich ./compose.rathole.immich.yml;

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      rathole_toml = {
        file = ../../../../secrets/rathole_toml.age;
        # Set correct owner otherwise docker cannot read the file
        #
        # Note rathole uses ID 1000 inside the container
        mode = "0600";
        owner = "unpriv-user1000";
        group = "unpriv-user1000";
      };
    };

    environment.etc = {
      "rathole/config.1.toml".
      source =
        if config.ahayzen.testing
        then ./rathole.vm.toml
        else config.age.secrets.rathole_toml.path;
    };
  };

}
