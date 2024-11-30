# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  services = {
    # Enable CUPS to print documents.
    printing = {
      enable = true;

      # Enable
      drivers = with pkgs; [ brlaser gutenprint hplip splix ];
    };

    # IPP over USB
    ipp-usb.enable = true;
  };
}
