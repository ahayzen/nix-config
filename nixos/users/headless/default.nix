# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }: {
  users.users.headless = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = config.ahayzen.publicKeys.hosts-openssh-headless-authorized ++ config.ahayzen.publicKeys.users-openssh-headless-authorized;
  };
}
