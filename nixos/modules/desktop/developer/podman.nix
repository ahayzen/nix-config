# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.podman-compose
  ];

  virtualisation.podman.enable = true;
}
