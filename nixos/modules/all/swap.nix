# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # Create a swapfile of 2GB
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2 * 1024;
    }
  ];

  # Enable compressed RAM
  #
  # this is useful on both headless and desktop systems
  zramSwap.enable = true;
}
