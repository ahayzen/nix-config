# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.sftpgo = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.sftpgo) {
    ahayzen = {
      docker-compose-files = [ ./compose.sftpgo.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/sftpgo/sftpgo.db ".backup /var/lib/docker-compose-runner/sftpgo/sftpgo-snapshot-$(date +%w).db"''
      ];
    };
  };
}
