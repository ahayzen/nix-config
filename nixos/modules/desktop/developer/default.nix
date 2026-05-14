# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }: {
  imports = [
    ./alacritty.nix
    ./llama-cpp.nix
    ./podman.nix
  ];
}
