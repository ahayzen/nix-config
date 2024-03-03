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

  # XPS 13 9360
  host__xps-13-9360 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1+V0m26Ni1WjixUmmYlSV7oE/zCvz/CHaafk3CmL+L";
  user__xps-13-9360__andrew = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq5KOXuuRBAPchTzslcD+/Lu89PUfsSxo6BiS90R0Svm71E5daDug+AaARgi6sUT0MaMzRsTCo885poqV9U+clY5C8sYBC+DbfZMS2LvqM8htXL8dbud3RzlBexcj27+8tVIvQntxU56Ok1l0T32nxMAnpMiCIsjsRyOOCjqJk0Flo2AdWP57So8j9j4N1PSfCGigzbpkuwqNwRsu64gPEaY/X0gqE4QkHzlydqhmMyDx9EXyhMrfE0g6ljeSURYjqXCB0pF0C8+MqcvkOOCTwrgL851ydBa71s43XxN4NLPQPQ4Cr+JFJE7oHtabg9QFg92vQqth0fAgnarsxijahfdTcIOgKkarCQrq7UPDkFxzr7o1ZrUPl6j8ckuMW3xem+3MeGynbkeJCljstaDOm96f1sQvI/n2aIwXqAIjCcZbmRCchiYpXicynDKfZOswqCmHozuny6/1azPNcEE6r0YXwyrdz38C4ZYjtcke5blZNRaUTJ/SkchKPGIMawGnPqYPssoElbKztHRfbPwJ9Cq8HU1XeqKd/PvIVFIYTnL8u84Hci3GWSvueEmzYG+QD60aI0jqsOG3BaV5/xIqAjZz+55tRvaPRu3Mcv/KWtDxaDTX0uJXawXqvaSer/d63jJX6w8oHTro8hM6IIi7avWIA8Wbja3+ikaZWNt7AjQ== andrew@andrew-XPS-13-9360";

  #
  # NAS
  #

  user__synology-nas__tunneller = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdt1obvMRaXsk41H6obsuyx6+RpDg6QhQ6rq32Zy673hhRynna4LKjHV/ECqq9AYhDtFPY0fvTrPy6Ls4OmIzk/XgB4zFN889WUSluDi6v29gWGhRSOx+BEcy8rVGOAOnmmNqaO8dM2XSMt5qXBiBBLzipvqgAiR3W4b8eJHwe90qF1cCMpZ9zbCWR3rylMk7E6dubfpLSzVVGoO/wMfwdmbflXcNTgHmkqy6lCkWwCWJ+7Fzko84nQ0l5rSImUjQya8IXaUC8aKTgeZG8VUpDiBL5lmif+6GjZ5GrVS1UK9UdDGog993WmZnmBhsH3uNI40GtCpExqFuvDd2FRHIX andrew@andrew-XPS-13-9360";

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
  hosts-secrets-desktop = [ host__thinkpad-t480 host__xps-13-9360 ];

  # Users that require access to desktop secrets
  #
  # This is for developers to manage secrets or manually deploy flakes
  users-secrets-desktop = [ user__thinkpad-t480__andrew-kdab user__xps-13-9360__andrew ];

  #
  # Access settings for OpenSSH authorizedKeys
  #

  # Users that might need access to headless hosts
  users-openssh-headless-authorized = [ user__thinkpad-t480__andrew-kdab user__xps-13-9360__andrew ];

  # Users that can create tunnels via VPS hosts
  users-openssh-vps-tunneller-authorized = [ user__synology-nas__tunneller ];

  # Hosts that are authorized to access headless hosts (eg for backup)
  hosts-openssh-headless-authorized = [ ];
}
