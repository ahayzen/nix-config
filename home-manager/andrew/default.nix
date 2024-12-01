# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ inputs, ... }: {
  imports = [
    ./alacritty.nix
    ./git.nix
    ./helix.nix
    ./zellij.nix
  ];

  # Set our catppuccin theme
  catppuccin = {
    flavor = "mocha";
  };

  home = {
    homeDirectory = "/home/andrew";
    stateVersion = "24.05";
    username = "andrew";
  };

  news.display = "silent";

  programs = {
    home-manager.enable = true;
  };
}
