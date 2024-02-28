# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }: {
  age.secrets.password_andrew.file = ../../../secrets/password_andrew.age;

  users.users.andrew = {
    description = "Andrew Hayzen";
    extraGroups = [
      # Ensure we are in dialout group to access embedded boards serial port
      "dialout"
      # Add us to the sudo group
      "wheel"
    ];
    hashedPasswordFile = config.age.secrets.password_andrew.path;
    isNormalUser = true;
    shell = pkgs.bashInteractive;
  };
}
