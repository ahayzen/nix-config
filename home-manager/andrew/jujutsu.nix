# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:
{
  programs = {
    jujutsu = {
      enable = true;

      settings = {
        # Enable SSH signing for all repos by default
        signing = {
          behavior = "own";
          backend = "ssh";
          key = "~/.ssh/id_ed25519.pub";
          backends.ssh."allowed-signers" = "~/.ssh/allowed_signers";
        };

        # Show digital signatures
        ui = {
          "show-cryptographic-signatures" = true;
        };

        user = {
          email = if !config.ahayzen.kdab then "ahayzen@gmail.com" else "andrew.hayzen@kdab.com";
          name = "Andrew Hayzen";
        };
      };
    };
  };
}

