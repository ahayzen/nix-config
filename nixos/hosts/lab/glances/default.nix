# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.lab.glances = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.glances) {
    ahayzen.docker-compose-files = [ ./compose.glances.yml ];
  };
}
