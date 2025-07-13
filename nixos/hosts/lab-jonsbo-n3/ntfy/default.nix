# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    ntfy_lab_jonsbo_n3_token = {
      file = ../../../../secrets/ntfy_lab_jonsbo_n3_token.age;
      mode = "0644";
      owner = "unpriv";
      group = "unpriv";
    };
  };

  environment.etc = {
    "ntfy/token".source =
      if config.ahayzen.testing
      then ./ntfy_token.vm
      else config.age.secrets.ntfy_lab_jonsbo_n3_token.path;
  };

  # Notify when the system boots or is shutdown
  systemd.services."system-running-notify" = {
    enable = !config.ahayzen.testing;
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/bin/sh -c '${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Title: System\" -H \"Priority: default\" -d \"Booted\" https://ntfy.hayzen.uk/lab-jonsbo-n3'";
      ExecStop = "/bin/sh -c '${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Title: System\" -H \"Priority: default\" -d \"Shutdown\" https://ntfy.hayzen.uk/lab-jonsbo-n3'";
    };
  };

  # Notify when an upgrade fails
  systemd.services."nixos-upgrade" = {
    serviceConfig = {
      ExecStopPost = [
        "/bin/sh -c 'if [ \"$$EXIT_STATUS\" != 0 ]; then ${pkgs.curl}/bin/curl -u :$(cat /etc/ntfy/token) -H \"Title: System Upgrade\" -H \"Priority: high\" -d \"Failure\" https://ntfy.hayzen.uk/lab-jonsbo-n3; fi'"
      ];
    };
  };

}
