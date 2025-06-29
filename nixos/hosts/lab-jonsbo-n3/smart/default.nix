# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:
{
  systemd = {
    services."smart-weekly" = {
      serviceConfig = {
        ExecStart =
          let
            python = pkgs.python3.withPackages (ps: with ps; [ pysmart ]);
          in
          "${python.interpreter} -u ${./smart_monitor.py}";
        Type = "oneshot";
      };
    };

    timers."smart-weekly" = {
      # Enable when not in testing mode
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Mon, 04:15";
        Unit = "smart-weekly.service";
        Persistent = true;
      };
    };
  };
}
