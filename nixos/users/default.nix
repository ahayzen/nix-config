# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  # TODO: loop through users on system
  imports = [ ./andrew ./andrew-kdab ./headless ];
  # ++ lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};
}
