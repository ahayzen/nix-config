# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  options.ahayzen.lab.wg-quick = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.wg-quick) {
    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      wg-lab-private = {
        file = ../../../../secrets/wg_lab_private.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "root";
        group = "root";
      };
    };

    networking.wg-quick.interfaces = {
      wg0 = {
        address = [ "172.28.228.2/24" ];
        dns = [ "9.9.9.9" ];
        listenPort = 51820;
        mtu = 1420;
        # Lab private key
        privateKeyFile = if config.ahayzen.testing then "${./wg-lab-test-private}" else config.age.secrets.wg-lab-private.path;
        peers = [
          {
            # VPS public key
            publicKey = if config.ahayzen.testing then "etSgGU6oJzeVY9hTESENy09pC2UVBMKAlqRpyGwC0wY=" else "x/OmP3Aa3i7XhsuoZT6svz56eLdv0E8oUtYV4jqkmTs=";
            allowedIPs = [ "172.28.228.0/24" ];
            endpoint = "ahayzen.com:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };

    networking.firewall =
      {
        allowedUDPPorts = [ 51820 ];
      };
  };
}
