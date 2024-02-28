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
    #
    # TODO: instead run manually with out own script ?
    # - collect garbage for preview +N profiles
    # - upgrade the host
    # - optimise the store
    # - reboot
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      # every Monday or every 4 hours try to upgrade
      randomizedDelaySec = "30m";
      dates = if headless then "Mon *-*-* 22:00" else "0/4:30";
      # on start don't trigger if missed, wait until the next
      persistent = false;
    };

    # Automatically optimise the store
    settings.auto-optimise-store = true;
  };

  # Define the platform that we are using
  nixpkgs.hostPlatform = "${platform}";

  system = {
    # Enble automatic upgrades
    autoUpgrade = {
      enable = true;
      flake = "github:ahayzen/nix-config";
      # don't auto reboot unless in headless mode
      allowReboot = headless;
      # apply on next reboot, not now
      operation = "boot";
      # every Wednesday or every 4 hours try to upgrade
      randomizedDelaySec = "30m";
      dates = if headless then "Wed *-*-* 22:00" else "0/4:00";
      # on start don't trigger if missed, wait until the next
      persistent = false;
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = stateVersion;
  };
}
