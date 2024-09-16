# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
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

    ahayzen = {
      docker-compose-files = [ ./compose.wagtail-ahayzen.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 ".backup /var/lib/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-$(date +%w).sqlite3"''
      ];
    };

    environment.etc = {
      "caddy/sites/ahayzen.Caddyfile".source = ./ahayzen.Caddyfile;
      "ahayzen.com/local.py".
      source =
        if config.ahayzen.testing
        then ./local.vm.py
        else config.age.secrets.local-py_ahayzen-com.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/ahayzen.Caddyfile".source)
      # Agenix path with a version that can be bumped
      "/etc/ahayzen/local.py-1"
    ];
  };
}
