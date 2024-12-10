# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

let
  # Hosts
  host = {
    diskstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRhsCMv/zMaGCNfsfUod7B02LgdaJdOWLiehgCQLl/1";
    desktop-scan-2017-kdab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoQC469TZahbh90wUMeyPW/72PtZqD4KRz+QfekehIx";
    laptop-thinkpad-t480-kdab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyQGokh7SHDi+mSwd3MgMAH0I0IF/BxG/tRiCYxKgPF";
    vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLzml0N0siR1R9l5Cfy9b8xURbCsYuheShVKyVAFu/d root@vps-904e01b6";
    lab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHWTIj0kjcH8z4LCUri8J/gugVldIpO+OfcGbSc4o8T root@andrew-Pangolin-Performance";
    xps-13-9360 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1+V0m26Ni1WjixUmmYlSV7oE/zCvz/CHaafk3CmL+L";
  };

  # Users
  user = {
    diskstation-forwarder = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdt1obvMRaXsk41H6obsuyx6+RpDg6QhQ6rq32Zy673hhRynna4LKjHV/ECqq9AYhDtFPY0fvTrPy6Ls4OmIzk/XgB4zFN889WUSluDi6v29gWGhRSOx+BEcy8rVGOAOnmmNqaO8dM2XSMt5qXBiBBLzipvqgAiR3W4b8eJHwe90qF1cCMpZ9zbCWR3rylMk7E6dubfpLSzVVGoO/wMfwdmbflXcNTgHmkqy6lCkWwCWJ+7Fzko84nQ0l5rSImUjQya8IXaUC8aKTgeZG8VUpDiBL5lmif+6GjZ5GrVS1UK9UdDGog993WmZnmBhsH3uNI40GtCpExqFuvDd2FRHIX andrew@andrew-XPS-13-9360";
    desktop-scan-2017-kdab-andrew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIuMYUGh7pv6bvnNF75zPkc3E7ZvFvNIYl52vo+UUz2 andrew@desktop-scan-2017-kdab";
    laptop-thinkpad-t480-kdab-andrew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaQAxzu5rJfJnO1zwW0XNRXnwpSl6vRsMnASfo1qVmB andrew@laptop-thinkpad-t480-kdab";
    xps-13-9360-andrew = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq5KOXuuRBAPchTzslcD+/Lu89PUfsSxo6BiS90R0Svm71E5daDug+AaARgi6sUT0MaMzRsTCo885poqV9U+clY5C8sYBC+DbfZMS2LvqM8htXL8dbud3RzlBexcj27+8tVIvQntxU56Ok1l0T32nxMAnpMiCIsjsRyOOCjqJk0Flo2AdWP57So8j9j4N1PSfCGigzbpkuwqNwRsu64gPEaY/X0gqE4QkHzlydqhmMyDx9EXyhMrfE0g6ljeSURYjqXCB0pF0C8+MqcvkOOCTwrgL851ydBa71s43XxN4NLPQPQ4Cr+JFJE7oHtabg9QFg92vQqth0fAgnarsxijahfdTcIOgKkarCQrq7UPDkFxzr7o1ZrUPl6j8ckuMW3xem+3MeGynbkeJCljstaDOm96f1sQvI/n2aIwXqAIjCcZbmRCchiYpXicynDKfZOswqCmHozuny6/1azPNcEE6r0YXwyrdz38C4ZYjtcke5blZNRaUTJ/SkchKPGIMawGnPqYPssoElbKztHRfbPwJ9Cq8HU1XeqKd/PvIVFIYTnL8u84Hci3GWSvueEmzYG+QD60aI0jqsOG3BaV5/xIqAjZz+55tRvaPRu3Mcv/KWtDxaDTX0uJXawXqvaSer/d63jJX6w8oHTro8hM6IIi7avWIA8Wbja3+ikaZWNt7AjQ== andrew@andrew-XPS-13-9360";
  };
in
{
  inherit host user;

  # Groups
  group = {
    hosts = {
      desktop = [
        host.desktop-scan-2017-kdab
        host.laptop-thinkpad-t480-kdab
        host.xps-13-9360
      ];

      headless = [
        host.lab
        host.vps
      ];
    };

    users = {
      developer = [
        user.desktop-scan-2017-kdab-andrew
        user.laptop-thinkpad-t480-kdab-andrew
        user.xps-13-9360-andrew
      ];
    };
  };
}
