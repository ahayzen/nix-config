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

    environment.etc = {
      "glances/glances.conf".source = ./glances.conf;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."glances/glances.conf".source)
    ];
  };
}
