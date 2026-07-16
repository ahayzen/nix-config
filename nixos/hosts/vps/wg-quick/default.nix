# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  options.ahayzen.vps.wg-quick = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.vps.wg-quick) {
    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      wg-pre-shared = {
        file = ../../../../secrets/wg_pre_shared.age;
        mode = "0600";
        owner = "root";
        group = "root";
      };

      wg-vps-private = {
        file = ../../../../secrets/wg_vps_private.age;
        mode = "0600";
        owner = "root";
        group = "root";
      };
    };

    ahayzen.docker-compose-files = [ ./compose.wg-quick.yml ];

    environment.etc = {
      "caddy/sites/wg-quick.Caddyfile".source = ./wg-quick.Caddyfile;
    };

    networking = {
      nat = {
        enable = true;
        externalInterface = if config.ahayzen.testing then "eth1" else "ens3";
        internalInterfaces = [ "wg0" ];
      };

      wg-quick.interfaces = {
        wg0 = {
          address = [ "172.28.228.129/32" ];
          dns = [ "9.9.9.9" "149.112.112.112" ];
          listenPort = 51821;
          mtu = 1420;
          # VPS private key
          privateKeyFile = if config.ahayzen.testing then "${./wg-vps-test-private}" else config.age.secrets.wg-vps-private.path;
          peers = [
            {
              # Lab public key
              publicKey = if config.ahayzen.testing then "iSJhX9/U0wZ/VyztUBnkEmFw9TVVPNtQwlmTCUaB2QY=" else "f/hmn0DmhLT0JoVrA8HtBEE3KbKvJgrT9u2UZk/Qc1w=";
              allowedIPs = [ "172.28.228.128/25" ];
              persistentKeepalive = 25;
              presharedKeyFile = if config.ahayzen.testing then "${./wg-pre-shared-test}" else config.age.secrets.wg-pre-shared.path;
            }
          ];
        };
      };
    };

    networking.firewall =
      {
        allowedUDPPorts = [ 51821 ];
      };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      (builtins.hashFile "sha256" config.environment.etc."caddy/sites/wg-quick.Caddyfile".source)
    ];
  };
}
