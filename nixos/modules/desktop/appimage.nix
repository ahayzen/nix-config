# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  programs.appimage = {
    # Enable appimage-run
    enable = true;

    # Recognise appimage files and use appimage-run to launch them
    binfmt = true;
  };
}
