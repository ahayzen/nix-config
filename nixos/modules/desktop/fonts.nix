# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  fonts = {
    # This should help flatpak find fonts, TODO: but might need a symlink too?
    # https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
    fontDir.enable = true;

    packages = with pkgs; [
      # TODO: gnome installs this
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
    ];
  };
}
