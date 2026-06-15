# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, pkgs, ... }:
{
  # Disable module from nixos stable as we want to use unstable
  # TODO: FUTURE: potentially remove after 26.05
  disabledModules = [
    "services/misc/llama-cpp.nix"
  ];

  imports = [
    # Force the whole service module to be from unstable so that we can use modelsPreset
    # TODO: FUTURE: potentially remove after 26.05
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/llama-cpp.nix"
  ];

  # Add llama-cpp to system packages so that it can be used from the terminal too
  #
  # TODO: FUTURE: potentially remove unstable after 26.05
  environment.systemPackages = [ inputs.nixpkgs-unstable.legacyPackages.${config.ahayzen.platform}.llama-cpp ];

  services.llama-cpp = {
    enable = true;

    settings = {
      host = "127.0.0.1";
      # NOTE: we use 11444 to not conflict with any ollama instance for now
      port = 11444;

      models-preset = pkgs.writeText "llama-models.ini" (lib.generators.toINI { } {
        "*" = {
          # Compress the KV cache
          #
          # NOTE: FUTURE: consider TurboQuant and accuracy
          # https://github.com/ggml-org/llama.cpp/pull/21089
          cache-type-k = "q8_0";
          cache-type-v = "q8_0";

          # Most models accept 128k so use this as our baseline
          ctx-size = "128000";

          # Auto unload models not used for 5 minutes
          sleep-idle-seconds = "300";
        };

        # AllenAI - olmo-3 / olmo-3.1
        # https://allenai.org/olmo
        # https://allenai.org/blog/olmo3
        "unsloth/Olmo-3-7B-Instruct-GGUF:Q4_K_M" = {
          hf-repo = "unsloth/Olmo-3-7B-Instruct-GGUF";
          hf-file = "Olmo-3-7B-Instruct-Q4_K_M.gguf";
          alias = "allenai/olmo-3-instruct:7b";
          ctx-size = "64000";
          # NOTE: bug in chat template requires jinja turning off
          jinja = "off";
          temperature = "0.6";
          top-p = "0.95";
        };
        "unsloth/Olmo-3-7B-Think-GGUF:Q4_K_M" = {
          hf-repo = "unsloth/Olmo-3-7B-Think-GGUF";
          hf-file = "Olmo-3-7B-Think-Q4_K_M.gguf";
          alias = "allenai/olmo-3-think:7b";
          ctx-size = "64000";
          temperature = "0.6";
          top-p = "0.95";
        };
        "unsloth/Olmo-3.1-32B-Instruct-GGUF:Q4_K_M" = {
          hf-repo = "unsloth/Olmo-3.1-32B-Instruct-GGUF";
          hf-file = "Olmo-3.1-32B-Instruct-Q4_K_M.gguf";
          alias = "allenai/olmo-3.1-instruct:32b";
          ctx-size = "64000";
          # NOTE: bug in chat template requires jinja turning off
          jinja = "off";
          temperature = "0.6";
          top-p = "0.95";
        };
        "unsloth/Olmo-3.1-32B-Think-GGUF:Q4_K_M" = {
          hf-repo = "unsloth/Olmo-3.1-32B-Think-GGUF";
          hf-file = "Olmo-3.1-32B-Think-Q4_K_M.gguf";
          alias = "allenai/olmo-3.1-think:32b";
          ctx-size = "64000";
          temperature = "0.6";
          top-p = "0.95";
        };

        # Google - gemma-4
        # https://deepmind.google/models/gemma/
        # https://deepmind.google/models/gemma/gemma-4/
        "google/gemma-4-E2B-it-qat-q4_0-gguf:IT" = {
          hf-repo = "google/gemma-4-E2B-it-qat-q4_0-gguf";
          hf-file = "gemma-4-E2B_q4_0-it.gguf";
          alias = "google/gemma-4:e2b";
          temperature = "1.0";
          top-k = "64";
          top-p = "0.95";
        };
        "google/gemma-4-E4B-it-qat-q4_0-gguf:IT" = {
          hf-repo = "google/gemma-4-E4B-it-qat-q4_0-gguf";
          hf-file = "gemma-4-E4B_q4_0-it.gguf";
          alias = "google/gemma-4:e4b";
          temperature = "1.0";
          top-k = "64";
          top-p = "0.95";
        };
        "google/gemma-4-12B-it-qat-q4_0-gguf:Q4_0" = {
          hf-repo = "google/gemma-4-12B-it-qat-q4_0-gguf";
          hf-file = "gemma-4-12b-it-qat-q4_0.gguf";
          alias = "google/gemma-4:12b";
          temperature = "1.0";
          top-k = "64";
          top-p = "0.95";
        };
        "google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0" = {
          hf-repo = "google/gemma-4-26B-A4B-it-qat-q4_0-gguf";
          hf-file = "gemma-4-26B_q4_0-it.gguf";
          alias = "google/gemma-4:26b-a4b";
          temperature = "1.0";
          top-k = "64";
          top-p = "0.95";
        };
        "google/gemma-4-31B-it-qat-q4_0-gguf:Q4_0" = {
          hf-repo = "google/gemma-4-31B-it-qat-q4_0-gguf";
          hf-file = "gemma-4-31B_q4_0-it.gguf";
          alias = "google/gemma-4:31b";
          temperature = "1.0";
          top-k = "64";
          top-p = "0.95";
        };

        # IBM - granite-4.1
        # https://www.ibm.com/granite
        # https://research.ibm.com/blog/granite-4-1-ai-foundation-models
        "ibm-granite/granite-4.1-3b-GGUF:Q4_K_M" = {
          hf-repo = "ibm-granite/granite-4.1-3b-GGUF";
          hf-file = "granite-4.1-3b-Q4_K_M.gguf";
          alias = "ibm-granite/granite-4.1:3b";
          temperature = "0.0";
          top-k = "0";
          top-p = "1.0";
        };
        "ibm-granite/granite-4.1-8b-GGUF:Q4_K_M" = {
          hf-repo = "ibm-granite/granite-4.1-8b-GGUF";
          hf-file = "granite-4.1-8b-Q4_K_M.gguf";
          alias = "ibm-granite/granite-4.1:8b";
          temperature = "0.0";
          top-k = "0";
          top-p = "1.0";
        };
        "ibm-granite/granite-4.1-30b-GGUF:Q4_K_M" = {
          hf-repo = "ibm-granite/granite-4.1-30b-GGUF";
          hf-file = "granite-4.1-30b-Q4_K_M.gguf";
          alias = "ibm-granite/granite-4.1:30b";
          temperature = "0.0";
          top-k = "0";
          top-p = "1.0";
        };

        # Mistral - ministral-3
        # https://mistral.ai/news/mistral-3
        "mistralai/Ministral-3-3B-Instruct-2512-GGUF:Q4_K_M" = {
          hf-repo = "mistralai/Ministral-3-3B-Instruct-2512-GGUF";
          hf-file = "Ministral-3-3B-Instruct-2512-Q4_K_M.gguf";
          alias = "mistralai/ministral-3-instruct:3b";
          temperature = "0.15";
          top-p = "0.95";
        };
        "mistralai/Ministral-3-3B-Reasoning-2512-GGUF:Q4_K_M" = {
          hf-repo = "mistralai/Ministral-3-3B-Reasoning-2512-GGUF";
          hf-file = "Ministral-3-3B-Reasoning-2512-Q4_K_M.gguf";
          alias = "mistralai/ministral-3-reasoning:3b";
          temperature = "0.7";
          top-p = "0.95";
        };
        "mistralai/Ministral-3-8B-Instruct-2512-GGUF:Q4_K_M" = {
          hf-repo = "mistralai/Ministral-3-8B-Instruct-2512-GGUF";
          hf-file = "Ministral-3-8B-Instruct-2512-Q4_K_M.gguf";
          alias = "mistralai/ministral-3-instruct:8b";
          temperature = "0.15";
          top-p = "0.95";
        };
        "mistralai/Ministral-3-8B-Reasoning-2512-GGUF:Q4_K_M" = {
          hf-repo = "mistralai/Ministral-3-8B-Reasoning-2512-GGUF";
          hf-file = "Ministral-3-8B-Reasoning-2512-Q4_K_M.gguf";
          alias = "mistralai/ministral-3-reasoning:8b";
          temperature = "0.7";
          top-p = "0.95";
        };
        "mistralai/Ministral-3-14B-Instruct-2512-GGUF:Q4_K_M" = {
          hf-repo = "mistralai/Ministral-3-14B-Instruct-2512-GGUF";
          hf-file = "Ministral-3-14B-Instruct-2512-Q4_K_M.gguf";
          alias = "mistralai/ministral-3-instruct:14b";
          temperature = "0.15";
          top-p = "0.95";
        };
        "mistralai/Ministral-3-14B-Reasoning-2512-GGUF:Q4_K_M" = {
          hf-repo = "mistralai/Ministral-3-14B-Reasoning-2512-GGUF";
          hf-file = "Ministral-3-14B-Reasoning-2512-Q4_K_M.gguf";
          alias = "mistralai/ministral-3-reasoning:14b";
          temperature = "1.0";
          top-p = "0.95";
        };
      });
    };

    # Do not open the firewall for llama-cpp externally
    openFirewall = false;

    # Use llama-cpp from unstable
    #
    # TODO: FUTURE: potentially remove after 26.05
    package = inputs.nixpkgs-unstable.legacyPackages.${config.ahayzen.platform}.llama-cpp;
  };
}

