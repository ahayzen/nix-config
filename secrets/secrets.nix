# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

let
  publicKeys = import ./keys.nix;
in
{
  "local-py_ahayzen-com.age".publicKeys = [ publicKeys.host.vps ] ++ publicKeys.group.user.developers;

  # mkpasswd -m sha-512
  #
  # TODO: check if trailing new line is OK for these
  "password_andrew.age".publicKeys = publicKeys.group.host.desktops ++ publicKeys.group.user.developers;

  "password_headless_recovery.age".publicKeys = publicKeys.group.host.headless ++ publicKeys.group.user.developers;
}
