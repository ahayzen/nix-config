# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }: {
  # Allow for passwordless sudo with headless user
  security.sudo.extraRules = [
    {
      users = [ "headless" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];

  # User for management
  age.secrets.password_headless_recovery.file = ../../../secrets/password_headless_recovery.age;

  users = {
    # Do not allow for changing users on a headless system manually
    mutableUsers = false;

    users = {
      # Set a recovery password for the root user
      root = {
        hashedPasswordFile = config.age.secrets.password_headless_recovery.path;
      };

      headless = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ];

        openssh.authorizedKeys.keys = config.ahayzen.publicKeys.group.user.developers;
      };
    };
  };
}
