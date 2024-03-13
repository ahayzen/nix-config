# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

# Create or edit secrets with
#
# ```console
# nix run github:ryantm/agenix -- -e password_andrew-kdab.age
# ```
#
# Rekey secrets with
#
# ```console
# nix run github:ryantm/agenix -- --rekey
# ```
let
  publicKeys = import ./keys.nix;
in
{
  "local-py_ahayzen-com.age".publicKeys = publicKeys.host-vps-ahayzen ++ publicKeys.users-secrets-desktop;

  # mkpasswd -m sha-512
  #
  # TODO: check if trailing new line is OK for these
  "password_andrew.age".publicKeys = publicKeys.hosts-secrets-desktop ++ publicKeys.users-secrets-desktop;
  "password_andrew-kdab.age".publicKeys = publicKeys.hosts-secrets-desktop ++ publicKeys.users-secrets-desktop;
}
