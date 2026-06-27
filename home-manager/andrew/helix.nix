# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  catppuccin.helix.enable = true;

  programs = {
    helix = {
      enable = true;

      defaultEditor = true;

      # Default language settings in Helix are defined here
      # https://github.com/helix-editor/helix/blob/master/languages.toml
      #
      # Enable auto-format for C/C++/QML which aren't enabled by default
      languages = {
        language = [
          {
            name = "c";
            auto-format = true;
          }
          {
            name = "cpp";
            auto-format = true;
          }
          {
            name = "qml";
            auto-format = true;
          }
        ];

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
