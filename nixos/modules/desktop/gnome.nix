# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  services = {
    # Do not install the apps for GNOME
    # https://nixos.org/manual/nixos/stable/#sec-gnome-without-the-apps
    gnome.core-utilities.enable = false;

    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Enable the GNOME Desktop Environment.
      desktopManager.gnome = {
        enable = true;

        extraGSettingsOverrides = ''
          # Enable week numbers in top bar calendar
          [org.gnome.desktop.calendar]
          show-weekdate = true

          # Enable automatic timezones from geoip
          [org.gnome.desktop.datetime]
          automatic-timezone = true

          # Touchpad tweaks
          [org.gnome.desktop.peripherals.touchpad]
          disable-while-typing = false
          tap-to-click = true


          # Enable dynamic workspaces
          [org.gnome.mutter]
          dynamic-workspaces = true
          edge-tiling = true


          # Enable night light
          [org.gnome.settings-daemon.plugins.color]
          night-light-enabled = true

          # Do not suspend when on AC after a period of time
          [org.gnome.settings-daemon.plugins.power]
          sleep-inactive-ac-type = 'nothing'


          # Fix alphabetical ordering of app picker and disable all extensions
          [org.gnome.shell]
          app-picker-layout = []
          enabled-extensions = []


          # Enable location services for night light and other apps
          [org.gnome.system.location]
          enabled = true
        '';

        extraGSettingsOverridePackages = [
          # org.gnome.desktop
          pkgs.gsettings-desktop-schemas
          # org.gnome.shell
          pkgs.gnome-shell
          # org.gnome.mutter
          pkgs.mutter
        ];
      };
      displayManager.gdm.enable = true;

      # We do not want xterm enabled
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };

  # Exclude packages from the base install
  environment.gnome.excludePackages = [
    # FIXME: Extensions app is still installed
    pkgs.gnome-shell-extensions
  ];

  # Install GNOME Core apps which do not have a flatpak
  environment.systemPackages = [
    # TODO: could be in usage later?
    pkgs.gnome-disk-utility
    # gnome-console -> alacritty
    pkgs.nautilus
    # TODO: is there an independent store, warehouse?
    pkgs.gnome-software
    # TODO: could be missioncenter or usage
    pkgs.gnome-system-monitor
    pkgs.gnome-tour
    pkgs.yelp
  ];

  # Install all GNOME Core apps except where we have common replacements
  services.flatpak.packages = lib.mkIf (!config.ahayzen.testing)
    [
      { appId = "org.gnome.baobab"; origin = "flathub-nix"; }
      { appId = "org.gnome.Boxes"; origin = "flathub-nix"; }
      { appId = "org.gnome.clocks"; origin = "flathub-nix"; }
      { appId = "org.gnome.Calculator"; origin = "flathub-nix"; }
      # org.gnome.Calendar -> Thunderbird
      { appId = "org.gnome.Characters"; origin = "flathub-nix"; }
      { appId = "org.gnome.Connections"; origin = "flathub-nix"; }
      # org.gnome.Contacts -> Thunderbird
      # org.gnome.Epiphany -> Firefox
      { appId = "org.gnome.Evince"; origin = "flathub-nix"; }
      { appId = "org.gnome.font-viewer"; origin = "flathub-nix"; }
      { appId = "org.gnome.Loupe"; origin = "flathub-nix"; }
      { appId = "org.gnome.Logs"; origin = "flathub-nix"; }
      { appId = "org.gnome.Maps"; origin = "flathub-nix"; }
      # org.gnnome.Music -> Finamp
      { appId = "org.gnome.SimpleScan"; origin = "flathub-nix"; }
      { appId = "org.gnome.Snapshot"; origin = "flathub-nix"; }
      { appId = "org.gnome.TextEditor"; origin = "flathub-nix"; }
      # org.gnome.Totem -> VLC
      { appId = "org.gnome.Weather"; origin = "flathub-nix"; }
      # Extra GNOME apps
      { appId = "org.gnome.FileRoller"; origin = "flathub-nix"; }
      { appId = "org.gnome.NautilusPreviewer"; origin = "flathub-nix"; }
    ];
}
