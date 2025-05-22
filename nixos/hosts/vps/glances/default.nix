# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.vps.glances = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.glances) {
    ahayzen.docker-compose-files = [ ./compose.glances.yml ];
  };
}
