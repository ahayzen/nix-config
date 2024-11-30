# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ inputs, ... }: {
  # Set our catppuccin theme
  catppuccin = {
    flavor = "mocha";
  };

  home.stateVersion = "24.05";

  programs = {
    # Use alacritty for our terminal as we want OSC 52 support
    alacritty = {
      enable = true;

      catppuccin.enable = true;
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

    git = {
      enable = true;

      aliases = {
        uncommit = "reset --soft HEAD^";
      };
      extraConfig = {
        rerere.enable = true;
      };
      lfs.enable = true;
      userEmail = "ahayzen@gmail.com";
      userName = "Andrew Hayzen";
    };

    # Use helix as our editor
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
          rules = [ 80 100 120 ];

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
      };
    };

    # Use zellij as our terminal multiplexer
    zellij = {
      enable = true;

      catppuccin.enable = true;
      enableBashIntegration = true;
      settings = {
        default_mode = "locked";
        # We do not want frames around each pane
        pane_frames = false;
        ui.pane_frames.hide_session_name = true;
        # TODO: rebinding of keys
      };
    };
  };
}
