# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }: {
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    password_andrew.file = ../../../secrets/password_andrew.age;
  };

  users.users.andrew = {
    description = "Andrew Hayzen";
    extraGroups = [
      # Ensure we are in cdrom group to be able to write to drives
      "cdrom"
      # Ensure we are in dialout group to access embedded boards serial port
      "dialout"
      # Add us to the sudo group
      "wheel"
    ];
    hashedPasswordFile = lib.mkIf (!config.ahayzen.testing) config.age.secrets.password_andrew.path;
    isNormalUser = true;
  };
}
