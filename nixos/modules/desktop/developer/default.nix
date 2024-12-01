# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  options.ahayzen.developer = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  imports = [
    ./alacritty.nix
    ./podman.nix
  ];
}
