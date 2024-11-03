# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  options.ahayzen = {
    headless = lib.mkOption {
      type = lib.types.bool;
    };

    platform = lib.mkOption {
      default = "x86_64-linux";
      type = lib.types.str;
    };

    testing = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  imports = [
    ./agenix.nix
    ./boot.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./shell.nix
    ./smart.nix
    ./swap.nix
  ];
}
