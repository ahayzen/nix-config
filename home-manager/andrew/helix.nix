# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  catppuccin.helix.enable = true;

  programs = {
    helix = {
      enable = true;

      defaultEditor = true;
      languages = {
        language = [{
          name = "cpp";
          auto-format = true;
        }];

        language-server.rust-analyzer.config.checkOnSave = false;
      };
      settings = {
        editor = {
          color-modes = true;
          cursorline = true;
          true-color = true;

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
      };
    };
  };
}
