# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  networking.networkmanager = {
    # Enable NetworkManager
    #
    # TODO: gnome enables this
    enable = true;

    # Use Quad9 for DNS
    # https://quad9.net/
    insertNameservers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
  };
}
