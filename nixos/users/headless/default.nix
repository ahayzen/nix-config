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
  users.users.headless = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];

    openssh.authorizedKeys.keys = config.ahayzen.publicKeys.group.user.developers;
  };
}
