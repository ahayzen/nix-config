# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:
{
  options.ahayzen = {
    periodic-daily-commands = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };

    periodic-weekly-commands = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    systemd = {
      services = {
        "periodic-daily" = {
          serviceConfig = {
            Type = "oneshot";
          };
          script = builtins.foldl'
            (commands: command: ''
              ${commands}
              ${command}
            '') ""
            config.ahayzen.periodic-daily-commands;
        };

        "periodic-weekly" = {
          serviceConfig = {
            Type = "oneshot";
          };
          script = builtins.foldl'
            (commands: command: ''
              ${commands}
              ${command}
            '') ""
            config.ahayzen.periodic-weekly-commands;
        };
      };

      timers = {
        "periodic-daily" = {
          # Only enable if there are commands
          enable = config.ahayzen.periodic-daily-commands != [ ];
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            Unit = "periodic-daily.service";
            RandomizedDelaySec = "30m";
            Persistent = true;
          };
        };

        "periodic-weekly" = {
          # Only enable if there are commands
          enable = config.ahayzen.periodic-weekly-commands != [ ];
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "weekly";
            Unit = "periodic-daily.service";
            RandomizedDelaySec = "30m";
            Persistent = true;
          };
        };
      };
    };
  };
}
