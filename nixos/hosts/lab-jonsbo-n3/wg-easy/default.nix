# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, pkgs, options, ... }:
{
  options.ahayzen.lab.wg-easy = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.wg-easy) {
    ahayzen = {
      docker-compose-files = [ ./compose.wg-easy.yml ];
    };

    # Needed for wg-easy
    #
    # NOTE: use nft hooks similar to podman setup as wg-easy still uses iptables
    # https://wg-easy.github.io/wg-easy/v15.3/examples/tutorials/podman-nft/#edit-hooks
    boot.kernelModules = [
      "nft_masq"
      "wireguard"
    ];

    environment.etc = {
      "coredns/Corefile".source = ./corefile;
      "traefik/dynamic/traefik.wg-easy.yml".source = ./traefik.wg-easy.yml;
    };

    networking.firewall =
      {
        allowedUDPPorts = [ 51820 ];
      };

    # Take a snapshot of the database daily
    systemd = {
      services."wg-easy-db-snapshot" = {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''
          /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/wg-easy/config
          /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/wg-easy/config/wg-easy.db ".backup /var/lib/docker-compose-runner/wg-easy/config/wg-easy-snapshot-$(date +%w).db"
        '';
      };

      timers."wg-easy-db-snapshot" = {
        enable = !config.ahayzen.testing;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "22:15";
          Unit = "wg-easy-db-snapshot.service";
          Persistent = true;
        };
      };

      # Restart if static files change
      #
      # Note agenix files are not possible and will need the version bumping
      # which causes the hash of the docker-compose file to change.
      services."docker-compose-runner".restartTriggers = [
        (builtins.hashFile "sha256" config.environment.etc."coredns/Corefile".source)
        (builtins.hashFile "sha256" config.environment.etc."traefik/dynamic/traefik.wg-easy.yml".source)
      ];
    };
  };
}
