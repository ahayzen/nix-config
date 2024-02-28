# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

let
  #
  # Public keys of hosts and users
  #

  #
  # PCs
  #

  # ThinkPad T480
  host__thinkpad-t480 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyQGokh7SHDi+mSwd3MgMAH0I0IF/BxG/tRiCYxKgPF";
  user__thinkpad-t480__andrew-kdab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7mlMIrnPEXlFDYBp8Eflpl9E0nDu03LiVQrtXbNLFS andrew@ThinkPad-T480";

  #
  # NAS
  #


  #
  # VPS
  #


in
{
  #
  # Decryption settings for Agenix secrets
  #

  # Hosts that require access to desktop secrets
  #
  # This is for automatic upgrades
  hosts-secrets-desktop = [ host__thinkpad-t480 ];

  # Users that require access to desktop secrets
  #
  # This is for developers to manage secrets or manually deploy flakes
  users-secrets-desktop = [ user__thinkpad-t480__andrew-kdab ];

  #
  # Access settings for OpenSSH authorizedKeys
  #

  # Users that so might need access to headless hosts
  users-openssh-headless-authorized = [ user__thinkpad-t480__andrew-kdab ];

  # Hosts that are authorized to access headless hosts (eg for backup)
  hosts-openssh-headless-authorized = [ ];
}
