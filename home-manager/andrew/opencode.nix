# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, osConfig, ... }:
{
  # TODO: FUTURE: nixos-26.05 enable opencode
  # https://github.com/catppuccin/nix/pull/794
  # catppuccin.opencode.enable = true;

  programs = {
    opencode = {
      enable = true;

      settings = {
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama (local)";
            options = {
              # Using the hostName works both inside and outside the container
              baseURL = "http://${if osConfig != null then osConfig.networking.hostName + ".local" else "localhost"}:11434/v1";
            };
            # Models need to be manually listed for now
            # https://github.com/anomalyco/opencode/issues/6231
            # https://github.com/anomalyco/opencode/pull/17670
            models = {
              # IBM Granite 4 models
              "ibm/granite4:350m-h" = {
                name = "ibm/granite4:350m-h";
              };
              "ibm/granite4:1b-h" = {
                name = "ibm/granite4:1b-h";
              };
              "ibm/granite4:3b-h" = {
                name = "ibm/granite4:3b-h";
              };
              "ibm/granite4:7b-a1b-h" = {
                name = "ibm/granite4:7b-a1b-h";
              };
              "ibm/granite4:32b-a9b-h" = {
                name = "ibm/granite4:32b-a9b-h";
              };
            };

            # TODO: FUTURE: potentially remove after 26.05
            package = inputs.nixpkgs-unstable.legacyPackages.${if osConfig != null then osConfig.ahayzen.platform else "x86_64-linux"}.opencode;
          };
        };
      };
    };
  };
}


