# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # Monitor disk SMART data
  services.smartd = {
    enable = true;

    autodetect = true;
  };
}
