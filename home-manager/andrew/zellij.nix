# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  catppuccin.zellij.enable = true;

  programs = {
    zellij = {
      enable = true;

      settings = {
        show_startup_tips = false;
        ui = {
          pane_frames = {
            hide_session_name = true;
          };
        };
      };
    };
  };
}
