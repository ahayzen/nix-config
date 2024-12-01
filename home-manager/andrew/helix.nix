# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  programs = {
    helix = {
      enable = true;

      catppuccin.enable = true;
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
          rulers = [ 80 100 120 ];

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
      };
    };
  };
}
