# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }: {
  # Create a swapfile of 1GB for headless and 2GB for desktop
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = if config.ahayzen.headless then 1024 else 2 * 1024;
    }
  ];

  # Enable compressed RAM
  #
  # this is useful on both headless and desktop systems
  zramSwap.enable = true;
}
