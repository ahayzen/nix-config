# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.actual = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.actual) {
    ahayzen = {
      docker-compose-files = [ ./compose.actual.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/actual/data/server-files/account.sqlite ".backup /var/lib/docker-compose-runner/actual/data/server-files/account-snapshot-$(date +%w).sqlite"''
      ];
    };
  };
}
