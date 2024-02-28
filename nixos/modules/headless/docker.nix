# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  options.ahayzen.docker-compose-file = lib.mkOption {
    default = "/srv/config/docker-compose.yml";
    type = lib.types.str;
  };

  config = {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    systemd = {
      services."docker-compose-runner" = {
        path = [ pkgs.docker-compose ];
        after = [ "docker.service" "docker.socket" "network-online.target" ];

        # TODO: we want this to run as a user somewhere
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";

          # TODO: check that we do not need pull on boot to increase boot speed
          # ExecStartPre = "-${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} pull --quiet";

          ExecStart = "${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans";
          # Use stop here so that we can reuse the same container on reboot (instead of down)
          ExecStop = "${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} stop";

          # Upon reload pull new container images and restart any containers
          ExecReload = ''
            ${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} pull --quiet
            ${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} up --detach--remove-orphans
          '';
        };
      };

      # Every day try to upgrade the docker containers
      services."docker-compose-upgrade" = {
        script = ''
          ${pkgs.systemd}/bin/systemctl reload-or-restart docker-compose-runner.service
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
      timers."docker-compose-upgrade" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          # TODO: choose the time to upgrade
          OnCalendar = "daily";
          Unit = "docker-compose-upgrade.service";
        };
      };
    };

    # timer
    # /bin/systemctl reload-or-restart docker-compose.service

    virtualisation.docker = {
      enable = true;

      # TODO: link this to when we update docker-compose?
      autoPrune.enable = true;
      rootless = {
        enable = true;

        # Set DOCKER_HOST for users
        setSocketVariable = true;
      };
    };
  };
}
