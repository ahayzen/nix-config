# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  environment.systemPackages =
    if config.ahayzen.developer
    then with pkgs; [ podman-compose ]
    else [ ];

  virtualisation.podman.enable = lib.mkIf config.ahayzen.developer true;
}
