# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  options.ahayzen.docker-compose-file = lib.mkOption {
    type = lib.types.path;
  };

  config = {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    systemd = {
      services."docker-compose-runner" = {
        path = [ pkgs.docker-compose ];
        after = [ "docker.service" "docker.socket" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";

          ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans";
          # Use stop here so that we can reuse the same container on reboot (instead of down)
          ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} stop";
        };

        # Upon reload pull new container images and restart any containers
        reload = ''
          ${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} pull --quiet
          ${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans
        '';

        # Reload if the docker-compose file changes
        #
        # Note that we use digest sha's so these change via nixos upgrade
        # and renovate automatically is finding these updates and committing them.
        # This avoids the need for a specific docker-compose-upgrade timer.
        reloadTriggers = [
          (builtins.hashFile "sha256" config.ahayzen.docker-compose-file)
        ];
      };
      # Do not use StateDirectory as it changes ownership to the service user on startup
      # eg this causes ownership to change to root rather than unpriv
      # Instead use a tmpfile rule with no age to cleanup
      tmpfiles.settings = {
        "99-docker-compose-runner" = {
          "/var/lib/docker-compose-runner" = {
            d = {
              age = "-";
              group = "unpriv";
              mode = "0750";
              user = "unpriv";
            };
          };
        };
      };
    };
  };
}
