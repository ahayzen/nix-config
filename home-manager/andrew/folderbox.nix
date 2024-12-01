# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.folderbox.packages.${pkgs.system}.default
  ];
}
