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

  users.users = {
    # User for management
    headless = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];

      openssh.authorizedKeys.keys = config.ahayzen.publicKeys.hosts-openssh-headless-authorized ++ config.ahayzen.publicKeys.users-openssh-headless-authorized;
    };

    # User for docker containers
    unpriv = {
      isNormalUser = true;

      openssh.authorizedKeys.keys = config.ahayzen.publicKeys.hosts-openssh-headless-authorized ++ config.ahayzen.publicKeys.users-openssh-headless-authorized;
    };
  };
}
