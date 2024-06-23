# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

let
  # Hosts
  host = {
    diskstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRhsCMv/zMaGCNfsfUod7B02LgdaJdOWLiehgCQLl/1";
    thinkpad-t480 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyQGokh7SHDi+mSwd3MgMAH0I0IF/BxG/tRiCYxKgPF";
    vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLzml0N0siR1R9l5Cfy9b8xURbCsYuheShVKyVAFu/d root@vps-904e01b6";
    lab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHWTIj0kjcH8z4LCUri8J/gugVldIpO+OfcGbSc4o8T root@andrew-Pangolin-Performance";
    xps-13-9360 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1+V0m26Ni1WjixUmmYlSV7oE/zCvz/CHaafk3CmL+L";
  };

  # Users
  user = {
    thinkpad-t480-andrew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7mlMIrnPEXlFDYBp8Eflpl9E0nDu03LiVQrtXbNLFS andrew@ThinkPad-T480";
    xps-13-9360-andrew = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq5KOXuuRBAPchTzslcD+/Lu89PUfsSxo6BiS90R0Svm71E5daDug+AaARgi6sUT0MaMzRsTCo885poqV9U+clY5C8sYBC+DbfZMS2LvqM8htXL8dbud3RzlBexcj27+8tVIvQntxU56Ok1l0T32nxMAnpMiCIsjsRyOOCjqJk0Flo2AdWP57So8j9j4N1PSfCGigzbpkuwqNwRsu64gPEaY/X0gqE4QkHzlydqhmMyDx9EXyhMrfE0g6ljeSURYjqXCB0pF0C8+MqcvkOOCTwrgL851ydBa71s43XxN4NLPQPQ4Cr+JFJE7oHtabg9QFg92vQqth0fAgnarsxijahfdTcIOgKkarCQrq7UPDkFxzr7o1ZrUPl6j8ckuMW3xem+3MeGynbkeJCljstaDOm96f1sQvI/n2aIwXqAIjCcZbmRCchiYpXicynDKfZOswqCmHozuny6/1azPNcEE6r0YXwyrdz38C4ZYjtcke5blZNRaUTJ/SkchKPGIMawGnPqYPssoElbKztHRfbPwJ9Cq8HU1XeqKd/PvIVFIYTnL8u84Hci3GWSvueEmzYG+QD60aI0jqsOG3BaV5/xIqAjZz+55tRvaPRu3Mcv/KWtDxaDTX0uJXawXqvaSer/d63jJX6w8oHTro8hM6IIi7avWIA8Wbja3+ikaZWNt7AjQ== andrew@andrew-XPS-13-9360";
  };
in
{
  inherit host user;

  # Groups
  group = {
    hosts = {
      desktop = [
        host.thinkpad-t480
        host.xps-13-9360
      ];

      headless = [
        host.lab
        host.vps
      ];
    };

    users = {
      developer = [
        user.thinkpad-t480-andrew
        user.xps-13-9360-andrew
      ];
    };
  };
}
