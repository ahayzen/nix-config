# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      settings = {
        alias = {
          uncommit = "reset --soft HEAD^";
        };
        rerere.enable = true;
        user.email = if !config.ahayzen.kdab then "ahayzen@gmail.com" else "andrew.hayzen@kdab.com";
        user.name = "Andrew Hayzen";
      };
    };
  };
}
