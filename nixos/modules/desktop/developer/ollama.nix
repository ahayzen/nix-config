# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, ... }:
{
  services.ollama = {
    enable = true;

    environmentVariables = {
      # Use an increased the context length, useful for opencode
      # https://docs.ollama.com/context-length
      # https://docs.ollama.com/integrations/opencode
      #
      # NOTE: opencode could configure itself in the future
      # https://github.com/anomalyco/opencode/issues/3250
      OLLAMA_CONTEXT_LENGTH = "65536";
    };

    # Allow for containers to be able to connect to ollama
    #
    # NOTE: use the following address from containers
    # docker: `http://host.docker.internal:11434/`
    # podman: `http://host.containers.internal:11434/`
    # Or use --add-host=alias:host-gateway or --network=host
    # Or use the hostname of the device eg mydevice.local
    host = "0.0.0.0";

    # Do not open the firewall for ollama externally
    openFirewall = false;

    # Use ollama from unstable
    #
    # TODO: FUTURE: potentially remove after 26.05
    package = inputs.nixpkgs-unstable.legacyPackages.${config.ahayzen.platform}.ollama;
  };
}

