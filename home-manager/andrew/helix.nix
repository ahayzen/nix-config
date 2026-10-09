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

        # Disable checking on save for rust-analyzer
        #
        # As this tends to be very slow blocking builds
        # instead manually run cargo check/clippy/test
        language-server.rust-analyzer.config.checkOnSave = false;
      };

      settings = {
        editor = {
          # Enable colour for the mode indicator
          color-modes = true;

          # Highlight the line of the cursor
          cursorline = true;

          # Enable soft wrapping for long lines in the view
          soft-wrap.enable = true;

          # Force true-color even if the terminal detection failed
          #
          # NOTE: this may not be required anymore, was this for running in containers?
          true-color = true;

          inline-diagnostics = {
            # Enable inline cursor diagnostics, these don't get in the way like the top right overlay
            cursor-line = "hint";
            # Do not enable other lines as when the file is being changed this causes lots of movement
            other-lines = "disable";
          };

          lsp = {
            # Display LSP progress messages below the status line
            display-progress-messages = true;

            # Display LSP inlay hints
            display-inlay-hints = true;
          };
        };
      };
    };
  };
}
