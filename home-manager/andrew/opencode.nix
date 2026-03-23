# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, osConfig, ... }:
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
              # Granite4 models
              "granite4:small-h" = {
                name = "granite4:small-h";
              };
              "granite4:tiny-h" = {
                name = "granite4:tiny-h";
              };
              "granite4:latest" = {
                name = "granite4:micro-h";
              };
              # Phi4 models
              "phi4:latest" = {
                name = "phi4";
              };
            };
          };
        };
      };
    };
  };
}


