# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.vps.rathole = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.rathole) {
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

    ahayzen.docker-compose-files = [ ./compose.rathole.yml ];

    environment.etc = {
      "caddy/sites/rathole.Caddyfile".source = ./rathole.Caddyfile;
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
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/rathole.Caddyfile".source)
      # Agenix path with a version that can be bumped
      "/etc/rathole/config.toml-4"
    ];
  };
}
