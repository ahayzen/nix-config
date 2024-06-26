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
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };
}
