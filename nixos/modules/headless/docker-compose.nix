# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  options.ahayzen.docker-compose-files = lib.mkOption {
    default = [ ];
    type = lib.types.listOf lib.types.path;
  };

  config = {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    systemd = {
      services."docker-compose-runner" =
        let
          docker-compose-file-args = builtins.foldl' (args: path: "${args} --file ${path}") "" config.ahayzen.docker-compose-files;
        in
        {
          # Only enable if there are docker compose files
          enable = config.ahayzen.docker-compose-files != [ ];
          path = [ pkgs.docker-compose ];
          after = [ "docker.service" "docker.socket" "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";

            ExecStart = "${pkgs.docker-compose}/bin/docker-compose ${docker-compose-file-args} up --detach --remove-orphans";
            # Use stop here so that we can reuse the same container on reboot (instead of down)
            ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${docker-compose-file-args} stop";
          };

          # Upon reload pull new container images and restart any containers
          reload = ''
            ${pkgs.docker-compose}/bin/docker-compose ${docker-compose-file-args} pull --quiet
            ${pkgs.docker-compose}/bin/docker-compose ${docker-compose-file-args} up --detach --remove-orphans
          '';

          # Reload if the docker-compose file changes
          #
          # Note that we use digest sha's so these change via nixos upgrade
          # and renovate automatically is finding these updates and committing them.
          # This avoids the need for a specific docker-compose-upgrade timer.
          reloadTriggers = map (path: builtins.hashFile "sha256" path) config.ahayzen.docker-compose-files;
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
