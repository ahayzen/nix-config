# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  services.flatpak.enable = true;
  systemd.services.configure-flathub-repo = {
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists system-flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # TODO: install common apps
  # com.bitwarden.desktop
  # com.discordapp.Discord
  # com.spotify.Client
  # com.unicornsonlsd.finamp
  # net.cozic.joplin_desktop
  # org.gimp.GIMP
  # org.inkscape.Inkscape
  # org.libreoffice.LibreOffice
  # org.localsend.localsend_app
  # org.mozilla.firefox
  # org.mozilla.Thunderbird
  # org.telegram.desktop
  # org.videolan.VLC
  # us.zoom.Zoom
}
