# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  imports = [
    ./appimage.nix
    ./bluetooth.nix
    ./boot.nix
    ./developer
    ./firewall.nix
    ./flatpak.nix
    ./fonts.nix
    ./fwupd.nix
    ./games
    ./gnome.nix
    ./locale.nix
    ./network.nix
    ./pipewire.nix
    ./printing.nix
    ./systemd.nix
    ./developer
  ];

  config.ahayzen.headless = false;
}
