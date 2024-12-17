# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, ... }:
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

  # Force null on desktop otherwise timezone cannot be chosen
  config.time.timeZone = lib.mkForce null;
}
