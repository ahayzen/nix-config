# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  # Add smartmon tools
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # Monitor disk SMART data
  services.smartd = {
    enable = true;

    autodetect = true;
  };
}
