# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

let
  publicKeys = import ./keys.nix;
in
{
  # Note use the following command for generating random tokens
  # `$(< /dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 256 | head -n 1)`

  "local-py_ahayzen-com.age".publicKeys = [ publicKeys.host.vps ] ++ publicKeys.group.users.developer;
  "local-py_yumekasaito-com.age".publicKeys = [ publicKeys.host.vps ] ++ publicKeys.group.users.developer;

  "bitwarden_env.age".publicKeys = [ publicKeys.host.lab-jonsbo-n3 ] ++ publicKeys.group.users.developer;
  "immich_env.age".publicKeys = [ publicKeys.host.lab-jonsbo-n3 ] ++ publicKeys.group.users.developer;
  "rathole_toml.age".publicKeys = [ publicKeys.host.lab-jonsbo-n3 publicKeys.host.vps ] ++ publicKeys.group.users.developer;
  "restic_offsite_env.age".publicKeys = [ publicKeys.host.lab-jonsbo-n3 ] ++ publicKeys.group.users.developer;
  "restic_password.age".publicKeys = [ publicKeys.host.lab-jonsbo-n3 ] ++ publicKeys.group.users.developer;
  "vikunja_env.age".publicKeys = [ publicKeys.host.lab-jonsbo-n3 ] ++ publicKeys.group.users.developer;

  # For avoiding new lines use
  # EDITOR="nano --nonewlines"
  #
  # For generating a Linux password use
  # mkpasswd -m sha-512
  "password_andrew.age".publicKeys = publicKeys.group.hosts.desktop ++ publicKeys.group.users.developer;
  "password_headless_recovery.age".publicKeys = publicKeys.group.hosts.headless ++ publicKeys.group.users.developer;
}
