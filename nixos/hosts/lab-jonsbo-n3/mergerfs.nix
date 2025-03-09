# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  # Disable filesystem check for mergerfs otherwise a warning occurs
  # https://github.com/nix-community/disko/issues/840
  fileSystems.mergerfs.noCheck = lib.mkForce true;
}
