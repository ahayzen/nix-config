# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:
{
  imports = [
    ./fail2ban.nix
  ];

  ahayzen.docker-compose-files = [ ./compose.caddy.yml ]
    ++ lib.optional config.ahayzen.testing ./compose.caddy.vm.yml;

  environment.etc = {
    "caddy/Caddyfile".source = ./Caddyfile;

    # When using a VM disable https certs
    "caddy/global/vm.Caddyfile" = lib.mkIf config.ahayzen.testing {
      source = ./global.vm.Caddyfile;
    };
  };

  # Ensure that http and https is open
  networking.firewall =
    {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };

  # Restart if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".restartTriggers = [
    (builtins.hashFile "sha256" config.environment.etc."caddy/Caddyfile".source)
  ];

  # Create folders for caddy logs and create a file so fail2ban doesn't crash
  system.activationScripts.mkdirCaddyLogDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/log/caddy
    chown unpriv:unpriv /var/log/caddy
    chmod 0755 /var/log/caddy

    touch /var/log/caddy/access.log
    chown unpriv:unpriv /var/log/caddy/access.log
    chmod 0755 /var/log/caddy/access.log
  '';
}
