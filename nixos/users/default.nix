# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, pkgs, usernames, ... }: {
  imports = map (username: ./${username}) usernames;

  users.defaultUserShell = pkgs.bashInteractive;
}
