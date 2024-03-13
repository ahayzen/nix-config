# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  options.ahayzen.docker-compose-file = lib.mkOption {
    type = lib.types.path;
  };

  config = {
    # Allow for rootless docker to bind to privileged ports
    # our lowest is http at 80
    #
    # TODO: can we limit this to just the docker process
    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
    };

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
          User = "headless";

          ExecStart = "${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans";
          # Use stop here so that we can reuse the same container on reboot (instead of down)
          ExecStop = "${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} stop";

          # Upon reload pull new container images and restart any containers
          ExecReload = ''
            ${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} pull --quiet
            ${pkgs.docker-compose} --file ${config.ahayzen.docker-compose-file} up --detach --remove-orphans
          '';
        };
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
      rootless = {
        enable = true;

        # Set DOCKER_HOST for users
        setSocketVariable = true;
      };
    };
  };
}
