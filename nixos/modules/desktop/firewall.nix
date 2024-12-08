# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  # TODO: allow common port ranges for mDNS etc?

  # GNOME can enable openssh to install and allow the port
  environment.systemPackages = [
    pkgs.openssh
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];
}
