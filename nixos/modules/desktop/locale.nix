# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  i18n = {
    # Select ibus as the input method and enable anthy and uniemoji
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ anthy uniemoji ];
    };

    # Show all locales in GNOME
    supportedLocales = [ "all" ];
  };


  # Configure keymap in X11
  services.xserver.xkb.layout = "gb";
}
