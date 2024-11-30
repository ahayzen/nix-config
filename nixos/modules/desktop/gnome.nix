# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
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
          pkgs.gnome.gnome-shell
        ];
      };
      displayManager.gdm.enable = true;

      # We do not want xterm enabled
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };

  # TODO: install the gnome apps
  # environment.gnome.excludePackages = (with pkgs; [
  #   baobab # org.gnome.baobab
  #   # TODO: cheese may change to snapshot
  #   gnome.cheese # org.gnome.Snapshot
  #   # TODO: eog may change to Loupe
  #   gnome.eog # org.gnome.Loupe
  #   epiphany # org.gnome.Epiphany
  #   gnome.file-roller # org.gnome.FileRoller
  #   gedit # org.gnome.TextEditor
  #   gnome-text-editor # org.gnome.TextEditor
  #   # Note: instead we use org.gnome.Evolution
  #   gnome.geary # org.gnome.Geary
  #   gnome.gnome-calculator # org.gnome.Calculator
  #   gnome.gnome-calendar # org.gnome.Calendar
  #   gnome.gnome-characters # org.gnome.Characters
  #   gnome.gnome-clocks # org.gnome.clocks
  #   # TODO; no flatpak yet, but should we use terminal or prompt?
  #   # gnome-console
  #   gnome.gnome-contacts # org.gnome.Contacts
  #   # TODO: no flatpak yet
  #   # gnome-disk-utility
  #   gnome.gnome-font-viewer # org.gnome.font-viewer
  #   gnome.gnome-logs # org.gnome.Logs
  #   gnome.gnome-maps # org.gnome.Maps
  #   gnome.gnome-music # org.gnome.Music
  #   gnome-photos # org.gnome.Photos
  #   # TODO: no flatpak yet, but is also linked to the system version
  #   # gnome-tour
  #   # TODO: no flatpak yet
  #   # gnome-system-monitor
  #   gnome.gnome-weather # org.gnome.Weather
  #   # TODO: no flatpak yet
  #   # nautilus
  #   gnome-connections # org.gnome.Connections
  #   simple-scan # org.gnome.SimpleScan
  #   gnome.seahorse # org.gnome.seahorse.Application
  #   gnome.sushi # org.gnome.NautilusPreviewer
  #   # Note: instead we use org.videolan.VLC
  #   gnome.totem # org.gnome.Totem
  #   # TODO: no flatpak yet, but is also linked to the system version
  #   # yelp
  # ]);

}
