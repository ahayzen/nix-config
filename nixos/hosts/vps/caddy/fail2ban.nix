# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }:
{
  environment.etc = {
    # Use a regex to match the JSON log lines from caddy from
    "fail2ban/filter.d/caddy-status.conf".text = lib.mkDefault (lib.mkAfter ''
      [Definition]
      failregex = ^.*"client_ip":"<HOST>",.*?"status":(?:401|403),.*$
      datepattern = "ts":{Epoch}
    '');
  };

  services.fail2ban.jails = {
    caddy.settings = {
      enabled = true;
      filter = "caddy-status";
      logpath = "/var/log/caddy/*.log";
      action = ''iptables-multiport[name=HTTP, port="http,https"]'';
      backend = "auto";
    };
  };
}
