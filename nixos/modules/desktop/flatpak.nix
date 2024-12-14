# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  # Allow for LocalSend to open ports
  networking.firewall = {
    allowedTCPPorts = [
      53317
    ];
    allowedUDPPorts = [
      53317
    ];
  };

  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "flathub-nix";
        # Use a different name so the remote appears second in gnome-software
        args = "--title='Flathub Nix'";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Install common packages, only install when not testing
    packages = lib.mkIf (!config.ahayzen.testing) [
      { appId = "com.bitwarden.desktop"; origin = "flathub-nix"; }
      { appId = "com.discordapp.Discord"; origin = "flathub-nix"; }
      { appId = "com.spotify.Client"; origin = "flathub-nix"; }
      { appId = "com.unicornsonlsd.finamp"; origin = "flathub-nix"; }
      { appId = "net.cozic.joplin_desktop"; origin = "flathub-nix"; }
      { appId = "org.gimp.GIMP"; origin = "flathub-nix"; }
      { appId = "org.inkscape.Inkscape"; origin = "flathub-nix"; }
      { appId = "org.libreoffice.LibreOffice"; origin = "flathub-nix"; }
      { appId = "org.localsend.localsend_app"; origin = "flathub-nix"; }
      { appId = "org.mozilla.firefox"; origin = "flathub-nix"; }
      { appId = "org.mozilla.Thunderbird"; origin = "flathub-nix"; }
      { appId = "org.telegram.desktop"; origin = "flathub-nix"; }
      { appId = "org.videolan.VLC"; origin = "flathub-nix"; }
      { appId = "us.zoom.Zoom"; origin = "flathub-nix"; }
    ];
  };
}
