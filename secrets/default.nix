# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }: {
  options.ahayzen.publicKeys = {
    host = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.str;
    };

    user = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.str;
    };

    group = {
      host = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      };

      user = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      };
    };
  };

  config.ahayzen.publicKeys = import ./keys.nix;
}
