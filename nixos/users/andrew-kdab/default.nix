# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }: {
  age.secrets.password_andrew-kdab.file = ../../../secrets/password_andrew-kdab.age;

  users.users.andrew-kdab = {
    description = "Andrew Hayzen (KDAB)";
    extraGroups = [
      # Ensure we are in dialout group to access embedded boards serial port
      "dialout"
      # Add us to the sudo group
      "wheel"
    ];
    hashedPasswordFile = config.age.secrets.password_andrew-kdab.path;
    isNormalUser = true;
  };
}
