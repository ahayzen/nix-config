# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ headless, pkgs, platform, stateVersion, ... }: {
  # For nix flakes to work
  environment.systemPackages = with pkgs; map lib.lowPrio [
    curl
    gitMinimal
  ];

  nix = {
    # Enable garbage collection
    gc = {
      automatic = true;
      randomizedDelaySec = "30m";
      dates = "daily";

      # TODO: instead change to +3 from nix-env --delete-generations
      options = "--delete-older-than 30d";
    };

    # Automatically optimise the store
    #
    # Note we don't use auto-optimise-store as this increases load during rebuilds
    optimise = {
      automatic = true;
      dates = "daily";

      # Has randomizedDelaySec of 30m by default
    };
  };

  # Define the platform that we are using
  nixpkgs.hostPlatform = "${platform}";

  system = {
    # Enble automatic upgrades
    autoUpgrade = {
      enable = true;
      flake = "github:ahayzen/nix-config";
      randomizedDelaySec = "30m";
      dates = "hourly";

      # don't auto reboot unless in headless mode
      allowReboot = headless;
      # apply on next reboot unless in headless mode
      operation = if headless then "switch" else "boot";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = stateVersion;
  };
}
