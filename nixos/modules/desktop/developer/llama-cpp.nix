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

      models-preset = builtins.toString ./llama-preset.ini;
    };

    # Do not open the firewall for llama-cpp externally
    openFirewall = false;

    # Use llama-cpp from unstable
    #
    # TODO: FUTURE: potentially remove after 26.05
    package = inputs.nixpkgs-unstable.legacyPackages.${config.ahayzen.platform}.llama-cpp;
  };
}

