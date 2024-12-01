# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  imports = [
    ./alacritty.nix
    ./folderbox.nix
    ./git.nix
    ./helix.nix
    ./zellij.nix
  ];

  options.ahayzen.kdab = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = {
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
  };
}
