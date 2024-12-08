# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # Reduce the stop timeout to 15s otherwise shutdown is blocked for 90s
  #
  # Fedora are trying to change the timeout to 20s
  # https://pagure.io/fedora-workstation/issue/163
  # There is a pull request upstream to make this change
  # https://github.com/systemd/systemd/pull/18386
  systemd = {
    extraConfig = "DefaultTimeoutStopSec=15s";
    user.extraConfig = "DefaultTimeoutStopSec=15s";
  };
}
