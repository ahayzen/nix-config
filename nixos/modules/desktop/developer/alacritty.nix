# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
let
  # Alacritty doesn't have a cursor theme set as there no global one in Nix
  # https://github.com/NixOS/nixpkgs/issues/22652
  # https://github.com/alacritty/alacritty/issues/6703
  # So for now force a theme otherwise there is no mouse cursor
  alacritty = pkgs.alacritty.overrideAttrs (finalAttrs: {
    postInstall = (finalAttrs.postInstall or "") + ''
      wrapProgram $out/bin/alacritty --set XCURSOR_THEME Adwaita
    '';
  });
in
{
  # Ensure that we always have a terminal installed
  environment.systemPackages = [
    alacritty
  ];
}
