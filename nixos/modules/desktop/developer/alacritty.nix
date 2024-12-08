# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  # Alacritty doesn't have a cursor theme set
  # https://github.com/alacritty/alacritty/issues/6703
  # as there no global default cursor theme in Nix
  # https://github.com/NixOS/nixpkgs/issues/22652
  # So for now force a theme otherwise there is no mouse cursor
  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
  };

  # Ensure that we always have a terminal installed
  environment.systemPackages = [
    pkgs.alacritty
  ];
}
