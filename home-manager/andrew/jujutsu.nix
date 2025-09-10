# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:
{
  programs = {
    jujutsu = {
      enable = true;

      settings = {
        user = {
          email = if !config.ahayzen.kdab then "ahayzen@gmail.com" else "andrew.hayzen@kdab.com";
          name = "Andrew Hayzen";
        };
      };
    };
  };
}

