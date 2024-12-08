# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # Reduce the stop timeout to 15s otherwise shutdown is blocked for 90s
  systemd = {
    extraConfig = [
      "DefaultTimeoutStopSec=15s"
    ];

    user.extraConfig = [
      "DefaultTimeoutStopSec=15s"
    ];
  };
}
