# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  boot.consoleLogLevel = 0;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];
  boot.plymouth.enable = true;
}
