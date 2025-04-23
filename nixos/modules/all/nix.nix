# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }: {
  # For nix flakes to work
  environment.systemPackages = with pkgs; map lib.lowPrio [
    curl
    gitMinimal
  ];

  # Allow for any firmware with a license allowing for redistribution
  hardware.enableRedistributableFirmware = true;

  nix = {
    # Disable channels as we are using flakes
    #
    # https://github.com/NixOS/nix/issues/2982#issuecomment-2477618346
    channel.enable = false;

    # Enable garbage collection
    gc = {
      # Enable when not in testing mode
      automatic = !config.ahayzen.testing;
      dates = if config.ahayzen.headless then "07:30" else "00/2:30";
      persistent = false;

      # For desktop machines when there are many kernels this can quickly fill
      # the EFI partition, so only keep 7 days.
      #
      # TODO: instead change to +3 from nix-env --delete-generations
      options = if config.ahayzen.headless then "--delete-older-than 30d" else "--delete-older-than 7d";
    };

    # Automatically optimise the store
    #
    # Note we don't use auto-optimise-store as this increases load during rebuilds
    optimise = {
      # Enable when not in testing mode
      automatic = !config.ahayzen.testing;
      dates = if config.ahayzen.headless then [ "11:30" ] else [ "01/2:30" ];
      # TODO: no persistent option

      # Has randomizedDelaySec of 30m by default
    };

    settings = {
      # Ensure that nix-command and flakes are enabled
      experimental-features = [ "nix-command" "flakes" ];

      # Do not cache tarballs that are downloaded
      # otherwise by default the flake tarball is cached 3600 seconds
      # which means rebuilds appear not to work
      tarball-ttl = 0;
    };
  };

  # Define the platform that we are using
  nixpkgs.hostPlatform = config.ahayzen.platform;

  system = {
    # Enble automatic upgrades
    autoUpgrade = {
      # Enable when not in testing mode
      enable = !config.ahayzen.testing;
      flake = "github:ahayzen/nix-config";
      dates = "hourly";
      persistent = false;

      # don't auto reboot unless in headless mode
      allowReboot = config.ahayzen.headless;
      # apply on next reboot unless in headless mode
      operation = if config.ahayzen.headless then "switch" else "boot";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.11";
  };

  # Do not run gc, optimise, or upgrade if another is running
  # as we have seen odd behaviour with things hangings
  systemd.services."nix-gc" = {
    serviceConfig = {
      ExecCondition = [
        ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nix-optimise.service ) != activ* ]]"''
        ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nixos-upgrade.service ) != activ* ]]"''
      ];
    };
    unitConfig = {
      ConditionACPower = true;
      # TODO: consider ConditionMemoryPressure=, ConditionCPUPressure=, ConditionIOPressure=
    };
  };
  systemd.services."nix-optimise" = {
    serviceConfig = {
      ExecCondition = [
        ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nix-gc.service ) != activ* ]]"''
        ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nixos-upgrade.service ) != activ* ]]"''
      ];
    };
    unitConfig = {
      ConditionACPower = true;
      # TODO: consider ConditionMemoryPressure=, ConditionCPUPressure=, ConditionIOPressure=
    };
  };
  systemd.services."nixos-upgrade" = {
    serviceConfig = {
      ExecCondition = [
        ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nix-gc.service ) != activ* ]]"''
        ''/bin/sh -c "[[ $( ${pkgs.systemd}/bin/systemctl is-active nix-optimise.service ) != activ* ]]"''
      ];
    };
    unitConfig = {
      ConditionACPower = true;
      # TODO: consider ConditionMemoryPressure=, ConditionCPUPressure=, ConditionIOPressure=
    };
  };
}
