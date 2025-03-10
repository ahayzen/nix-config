# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }:
{
  boot = {
    consoleLogLevel = lib.mkDefault 0;
    initrd.systemd.enable = true;
    kernelParams = [ "quiet" "udev.log_level=3" ];
    plymouth.enable = true;
  };
}
