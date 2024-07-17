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
        mode = "0666";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    ahayzen.docker-compose-files = [ ./compose.rathole.yml ];

    environment.etc = {
      "caddy/sites/rathole.Caddyfile".source =
        if config.ahayzen.testing
        then ./rathole.Caddyfile.vm
        else ./rathole.Caddyfile;
      "rathole/config.1.toml".
      source =
        if config.ahayzen.testing
        then ./rathole.vm.toml
        else config.age.secrets.rathole_toml.path;
    };

    # Reload if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".reloadTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/rathole.Caddyfile".source)
    ];
  };
}
