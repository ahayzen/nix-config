# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, ... }:
{
  options.ahayzen.lab.bitwarden = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.bitwarden) {
    ahayzen.docker-compose-files = [ ./compose.bitwarden.yml ];

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      bitwarden_env = {
        file = ../../../../secrets/bitwarden_env.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    environment.etc = {
      "bitwarden/settings.1.env".
      source =
        if config.ahayzen.testing
        then ./bitwarden.vm.env
        else config.age.secrets.bitwarden_env.path;
    };
  };
}
