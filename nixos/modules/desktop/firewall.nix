# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }:
{
  # TODO: allow common port ranges for mDNS etc?

  # GNOME can enable openssh to install and allow the port
  services.openssh = {
    enable = true;

    openFirewall = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
    };
  };
  # Do not enable it by default
  systemd.services.sshd.wantedBy = lib.mkForce [ ];
}
