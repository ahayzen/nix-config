# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./developer.nix
    ./firewall.nix
    ./flatpak.nix
    ./fonts.nix
    ./fwupd.nix
    ./games.nix
    ./gnome.nix
    ./locale.nix
    ./network.nix
    ./pipewire.nix
    ./printing.nix
    ./developer
  ];

  config.ahayzen.headless = false;
}
