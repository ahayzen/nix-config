# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.vps.wagtail-yumekasaito = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.wagtail-yumekasaito) {
    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      local-py_yumekasaito-com = {
        file = ../../../../secrets/local-py_yumekasaito-com.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    ahayzen = {
      docker-compose-files = [ ./compose.wagtail-yumekasaito.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 ".backup /var/lib/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-$(date +%w).sqlite3"''
      ];
    };

    environment.etc = {
      "caddy/sites/yumekasaito.Caddyfile".source = ./yumekasaito.Caddyfile;
      "yumekasaito.com/local.1.py".
      source =
        if config.ahayzen.testing
        then ./local.vm.py
        else config.age.secrets.local-py_yumekasaito-com.path;
    };

    # Reload if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".reloadTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/yumekasaito.Caddyfile".source)
    ];
  };
}
