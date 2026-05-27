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

      # TODO: FUTURE: potentially remove after 26.05
      package = inputs.nixpkgs-unstable.legacyPackages.${if osConfig != null then osConfig.ahayzen.platform else "x86_64-linux"}.opencode;

      # Custom settings for opencode
      # https://opencode.ai/docs/config/
      settings = {
        # Disable auto update checks as we use Nix
        # https://opencode.ai/docs/config/#autoupdate
        autoupdate = false;

        # Only enable our llama-cpp provider
        # https://opencode.ai/docs/config/#enabled-providers
        enabled_providers = [ "llama-cpp" ];

        # Default model for tasks
        # https://opencode.ai/docs/models/#set-a-default
        model = "llama-cpp/ibm-granite/granite-4.1:8b";

        # Override default permissions to be more restrictive
        # https://opencode.ai/docs/permissions#available-permissions
        permission = {
          # Ask when running arbritary bash commands
          bash = "ask";
          # Ask when accessing the internet
          codesearch = "ask";
          webfetch = "ask";
          websearch = "ask";
        };

        provider = {
          # Setup llama-cpp as our provider
          # https://opencode.ai/docs/providers#llamacpp
          llama-cpp = {
            npm = "@ai-sdk/openai-compatible";
            name = "llama-cpp";
            options = {
              baseURL = "http://localhost:11444/v1";
            };
            # Models need to be manually listed for now
            # https://github.com/anomalyco/opencode/issues/6231
            # https://github.com/anomalyco/opencode/pull/17670
            models = {
              # IBM Granite 4.1 models
              # https://www.ibm.com/granite
              "ibm-granite/granite-4.1:3b" = {
                name = "ibm-granite/granite-4.1:3b";
                limit = {
                  context = 128000;
                  output = 65536;
                };
              };
              "ibm-granite/granite-4.1:8b" = {
                name = "ibm-granite/granite-4.1:8b";
                limit = {
                  context = 128000;
                  output = 65536;
                };
              };
              "ibm-granite/granite-4.1:30b" = {
                name = "ibm-granite/granite-4.1:30b";
                limit = {
                  context = 128000;
                  output = 65536;
                };
              };
            };
          };
        };

        # Disable sharing of conversations
        # https://opencode.ai/docs/config/#sharing
        share = "disabled";
      };
    };
  };
}


