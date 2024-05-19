# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }: {
  # TODO: FUTURE: 24.05: investigate `boot.loader.systemd-boot.bootCounting`
  # for automatic boot assessment with systemd-boot
  # https://github.com/NixOS/nixpkgs/pull/284135/
  boot = {
    initrd = {
      # Enable systemd for stage 1
      #
      # TODO: FUTURE: this might become default
      systemd.enable = true;

      # When using systemd enable LVM support otherwise cannot boot
      services.lvm.enable = true;
    };

    loader = {
      efi = {
        # Allow for reordering the boot entries
        canTouchEfiVariables = true;
      };

      # Enable systemd boot
      systemd-boot = {
        enable = lib.mkDefault true;
        configurationLimit = 10;
        memtest86.enable = !config.ahayzen.headless;
      };

      # When headless have a reduced timeout to decrease boot times
      timeout = if config.ahayzen.headless then 1 else 5;
    };
  };
}
