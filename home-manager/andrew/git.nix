# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  programs = {
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
  };
}
