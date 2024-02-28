# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  hardware.bluetooth = {
    # TODO: gnome enables this?
    enable = true;
    settings = {
      # Enable A2DP Sink
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
