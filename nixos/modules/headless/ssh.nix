# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [
      8022
    ];
    settings = {
      # Allow for SSH tunnels for secondary OpenVPN port
      GatewayPorts = "yes";
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };
}
