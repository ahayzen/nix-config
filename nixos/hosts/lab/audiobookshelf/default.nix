# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.audiobookshelf = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.audiobookshelf) {
    ahayzen = {
      docker-compose-files = [ ./compose.audiobookshelf.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/audiobookshelf/config/absdatabase.sqlite ".backup /var/lib/docker-compose-runner/audiobookshelf/config/absdatabase-snapshot-$(date +%w).sqlite"''
      ];
    };
  };
}
