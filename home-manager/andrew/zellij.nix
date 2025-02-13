# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # zellij uses kdl which is hard to configure in until extraConfig exists
  # https://github.com/nix-community/home-manager/issues/4659
  # catppuccin.zellij.enable = true;

  programs = {
    zellij = {
      enable = true;

      # zellij uses kdl which is hard to configure in until extraConfig exists
      # https://github.com/nix-community/home-manager/issues/4659
      #
      # settings = {
      #   # We do not want frames around each pane
      #   pane_frames = false;
      #   ui.pane_frames.hide_session_name = true;
      # };
    };
  };

  xdg.configFile."zellij/config.kdl".source = ./zellij-config.kdl;
}
