# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  # TODO: set default container to ubuntu
  #
  # TODO: investigate distrobox assemble
  environment.systemPackages =
    if config.ahayzen.developer
    then with pkgs; [ distrobox ]
    else [ ];
}
