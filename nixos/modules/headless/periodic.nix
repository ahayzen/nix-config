# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  systemd = {
    services."periodic-daily" = {
      serviceConfig = {
        Type = "oneshot";
      };
    };

    timers."periodic-daily" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "periodic-daily.service";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };
  };
}
