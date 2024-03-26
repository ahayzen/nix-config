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

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          StateDirectory = "docker-compose-runner";
          StateDirectoryMode = "0750";

          ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans";
          # Use stop here so that we can reuse the same container on reboot (instead of down)
          ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} stop";
        };

        # Upon reload pull new container images and restart any containers
        reload = ''
          ${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} pull --quiet
          ${pkgs.docker-compose}/bin/docker-compose --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans
        '';
      };

      # Every hour try to upgrade the docker containers
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
          OnCalendar = "hourly";
          Unit = "docker-compose-upgrade.service";
          RandomizedDelaySec = "30m";
          Persistent = true;
        };
      };
    };

    virtualisation.docker = {
      enable = true;

      autoPrune = {
        enable = true;
        dates = "daily";
      };

      daemon.settings = {
        dns = [ "9.9.9.9" ];
        no-new-privileges = true;
        userns-remap = "unpriv:users";
      };

      # rootless is too problematic as it requires services to run as user services
      # which has issues with linger on nix and the DOCKER_HOST is not set in systemd
      # rootless = {
      #   enable = true;
      #
      #   # Set DOCKER_HOST for users
      #   setSocketVariable = true;
      # };
    };
  };
}
