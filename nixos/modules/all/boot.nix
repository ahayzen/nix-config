# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, headless, ... }: {
  # TODO: FUTURE: 24.05: investigate `boot.loader.systemd-boot.bootCounting`
  # for automatic boot assessment with systemd-boot
  # https://github.com/NixOS/nixpkgs/pull/284135/
  boot.loader = {
    efi = {
      # Allow for reordering the boot entries
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    # Enable systemd boot
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = 10;
      memtest86.enable = !headless;
    };

    # When headless have a reduced timeout to decrease boot times
    timeout = if headless then 1 else 5;
  };
}
