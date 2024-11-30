# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  # TODO: install games and add a config option
  options.ahayzen.games = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };
}
