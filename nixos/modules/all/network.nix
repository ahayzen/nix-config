# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }: {
  options.ahayzen.hostName = lib.mkOption {
    type = lib.types.str;
  };

  # Define the hostname of the device
  config.networking.hostName = config.ahayzen.hostName;
}
