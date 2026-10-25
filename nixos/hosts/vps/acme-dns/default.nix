# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:
{
  ahayzen.docker-compose-files = [ ./compose.acme-dns.yml ];

  environment.etc = {
    "acme-dns/config.cfg".source = ./acme-dns.cfg;
    "caddy/sites/acme-dns.Caddyfile".source = ./acme-dns.Caddyfile;
  };

  # Ensure that dns is open
  networking.firewall =
    {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

  # Take a snapshot of the database daily
  systemd = {
    services."acme-db-snapshot" = {
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/acme-dns/data
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/acme-dns/data/acme-dns.db ".backup /var/lib/docker-compose-runner/acme-dns/data/acme-dns-snapshot-$(date +%w).db"
      '';
    };

    timers."acme-db-snapshot" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:15";
        Unit = "acme-db-snapshot.service";
        Persistent = true;
      };
    };
  };


  # Restart if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".restartTriggers = [
    (builtins.hashFile "sha256" config.environment.etc."acme-dns/config.cfg".source)
    (builtins.hashFile "sha256" config.environment.etc."caddy/sites/acme-dns.Caddyfile".source)
  ];
}
