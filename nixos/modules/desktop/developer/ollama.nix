# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  services.ollama = {
    enable = true;

    # Allow for containers to be able to connect to ollama
    #
    # NOTE: use the following address from containers
    # docker: `http://host.docker.internal:11434/`
    # podman: `http://host.containers.internal:11434/`
    # Or use --add-host=alias:host-gateway or --network=host
    host = "0.0.0.0";

    # Do not open the firewall for ollama externally
    openFirewall = false;
  };
}

