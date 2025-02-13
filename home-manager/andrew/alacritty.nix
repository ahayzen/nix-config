# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  catppuccin.alacritty.enable = true;

  programs = {
    # Use alacritty for our terminal as we want OSC 52 support
    alacritty = {
      enable = true;

      settings = {
        env.TERM = "xterm-256color";
        keyboard.bindings = [
          {
            key = "F11";
            action = "ToggleFullscreen";
          }
        ];
        window.startup_mode = "Maximized";
      };
    };
  };
}
