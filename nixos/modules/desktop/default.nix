# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ developer, games, lib, ... }: {
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./firewall.nix
    ./flatpak.nix
    ./fonts.nix
    ./fwupd.nix
    ./gnome.nix
    ./locale.nix
    ./network.nix
    ./pipewire.nix
    ./printing.nix
    ./developer
  ]
  # Include developer config
  ++ lib.optional (developer) ./developer
  # Include games config
  ++ lib.optional (games) ./games;
}
