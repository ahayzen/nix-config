# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.vps.homepage = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.homepage) {
    ahayzen = {
      docker-compose-files = [ ./compose.homepage.yml ];
    };

    environment.etc = {
      "caddy/sites/homepage.Caddyfile".source =
        if config.ahayzen.testing
        then ./homepage.Caddyfile.vm
        else ./homepage.Caddyfile;
      "homepage/bookmarks.yaml".source = ./bookmarks.yaml;
      "homepage/services.yaml".source = ./services.yaml;
      "homepage/settings.yaml".source = ./settings.yaml;
      "homepage/widgets.yaml".source = ./widgets.yaml;
    };

    # Reload if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".reloadTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/homepage.Caddyfile".source)
      (builtins.hashFile "sha256" config.environment.etc."homepage/bookmarks.yaml".source)
      (builtins.hashFile "sha256" config.environment.etc."homepage/services.yaml".source)
      (builtins.hashFile "sha256" config.environment.etc."homepage/settings.yaml".source)
      (builtins.hashFile "sha256" config.environment.etc."homepage/widgets.yaml".source)
    ];
  };
}
