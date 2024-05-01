# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

let
  publicKeys = import ./keys.nix;
in
{
  "local-py_ahayzen-com.age".publicKeys = [ publicKeys.host.vps ] ++ publicKeys.group.users.developer;
  "local-py_yumekasaito-com.age".publicKeys = [ publicKeys.host.vps ] ++ publicKeys.group.users.developer;

  # mkpasswd -m sha-512
  "password_andrew.age".publicKeys = publicKeys.group.hosts.desktop ++ publicKeys.group.users.developer;
  "password_headless_recovery.age".publicKeys = publicKeys.group.hosts.headless ++ publicKeys.group.users.developer;
}
