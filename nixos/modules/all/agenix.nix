# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, ... }: {
  # Tell age where the ssh keys are likely to be
  age = {
    identityPaths = [
      # host keys from services.openssh.hostKeys
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_ed25519_key"
      # other places that the ssh key might be
      # TODO: loop through possibles users?
      "/home/andrew/.ssh/id_rsa"
      "/home/andrew-kdab/.ssh/id_rsa"
    ];
  };

  # Ensure that agenix is installed on systems so that they can autoupdate
  environment.systemPackages = [
    inputs.agenix.packages.${config.ahayzen.platform}.agenix
  ];
}
