# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  services.flatpak.enable = true;
  systemd.services.configure-flathub-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub-system https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # TODO: install common apps
}
