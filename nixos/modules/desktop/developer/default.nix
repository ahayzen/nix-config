# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  imports = [
    ./alacritty.nix
    ./podman.nix
  ];
}
