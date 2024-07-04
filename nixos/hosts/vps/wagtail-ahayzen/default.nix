# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.vps.wagtail-ahayzen = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.wagtail-ahayzen) {
    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      local-py_ahayzen-com = {
        file = ../../../../secrets/local-py_ahayzen-com.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    ahayzen.docker-compose-files = [ ./compose.wagtail-ahayzen.yml ];

    environment.etc = {
      "caddy/sites/ahayzen.Caddyfile".source =
        if config.ahayzen.testing
        then ./ahayzen.Caddyfile.vm
        else ./ahayzen.Caddyfile;
      "ahayzen.com/local.1.py".
      source =
        if config.ahayzen.testing
        then ./local.vm.py
        else config.age.secrets.local-py_ahayzen-com.path;
    };

    # Reload if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".reloadTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/ahayzen.Caddyfile".source)
    ];
  };
}