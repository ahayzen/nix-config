# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  # Ensure that we always have a terminal installed
  environment.systemPackages = [
    pkgs.alacritty
  ];
}
