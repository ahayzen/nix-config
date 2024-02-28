# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }: {
  options.ahayzen.publicKeys = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
  };

  config.ahayzen.publicKeys = import ./keys.nix;
}
