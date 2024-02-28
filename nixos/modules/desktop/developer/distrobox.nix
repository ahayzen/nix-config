# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  # TODO: set default container to ubuntu
  #
  # TODO: investigate distrobox assemble
  environment.systemPackages = with pkgs; [
    distrobox
  ];
}
