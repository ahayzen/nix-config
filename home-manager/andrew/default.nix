# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  imports = [
    ./alacritty.nix
    ./distrobox.nix
    ./folderbox.nix
    ./git.nix
    ./gnome.nix
    ./helix.nix
    ./just.nix
    ./jujutsu.nix
    ./starship.nix
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
      # Session variables are only set if home-manager is managing your shell
      # or if you manually source the hm-session-vars.sh file
      # https://nix-community.github.io/home-manager/index.xhtml#_why_are_the_session_variables_not_set
      bash.enable = true;
      home-manager.enable = true;
    };
  };
}
