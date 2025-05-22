# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.lab.rathole = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.rathole) {
    ahayzen.docker-compose-files = [ ./compose.rathole.yml ];

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
      "rathole/config.toml".
      source =
        if config.ahayzen.testing
        then ./rathole.vm.toml
        else config.age.secrets.rathole_toml.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      # Agenix path with a version that can be bumped
      "/etc/rathole/config.toml-5"
    ];
  };
}
