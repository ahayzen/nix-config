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
      sessionVariables = {
        # Custom bash prompt adapted from
        # https://bash-prompt-generator.org/
        #
        # user@host:/current/work/dir
        # 0 (branch) $
        #
        # Use prompt command as helper
        # - Store the exit code so it's not lost
        # - Store the git branch name if there is one
        PROMPT_COMMAND = ''PS1_CMD1=$?; PS1_CMD2=$(git branch --show-current 2>/dev/null)'';
        # First line is [lime]user@hostname[/lime]:[aqua]/path[/aqua]
        # Second line has optional components
        # - [red]exit status[/red] (if not zero)
        # - [yellow](branch)[/yellow] (if git branch)
        # - prompt
        PS1 = ''\[\e[92;1m\]\u@\h\[\e[0m\]:\[\e[96;1m\]\w\n\[\e[91m\]$([[ $PS1_CMD1 == 0 ]] || echo "$PS1_CMD1 ")\[\e[0m\]\[\e[93;1m\]$([[ $PS1_CMD2 == "" ]] || echo "("$PS1_CMD2") ")\[\e[0m\]\[\e[92;1m\]\$\[\e[0m\] '';
      };
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
