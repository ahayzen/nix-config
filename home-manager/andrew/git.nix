# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:
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
      userEmail = if !config.ahayzen.kdab then "ahayzen@gmail.com" else "andrew.hayzen@kdab.com";
      userName = "Andrew Hayzen";
    };
  };
}
