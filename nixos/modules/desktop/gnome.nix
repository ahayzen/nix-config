# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }: {
  services = {
    # Do not install the apps for GNOME
    # https://nixos.org/manual/nixos/stable/#sec-gnome-without-the-apps
    gnome.core-apps.enable = false;

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

        # Mouse tweaks
        [org.gnome.desktop.peripherals.mouse]
        accel-profile = "flat"

        # Touchpad tweaks
        [org.gnome.desktop.peripherals.touchpad]
        disable-while-typing = false
        tap-to-click = true


        # Enable dynamic workspaces
        [org.gnome.mutter]
        dynamic-workspaces = true
        edge-tiling = true
        experimental-features = ['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']


        # Enable night light
        [org.gnome.settings-daemon.plugins.color]
        night-light-enabled = true

        # Do not suspend when on AC after a period of time
        [org.gnome.settings-daemon.plugins.power]
        sleep-inactive-ac-type = 'nothing'


        # Fix alphabetical ordering of app picker and disable all extensions
        [org.gnome.shell]
        app-picker-layout = []
        disable-user-extensions = false
        # NOTE: could potentially use pkgs.gnome.Extensions.places-status-indicator.extensionUuid instead
        enabled-extensions = ['apps-menu@gnome-shell-extensions.gcampax.github.com', 'drive-menu@gnome-shell-extensions.gcampax.github.com', 'places-menu@gnome-shell-extensions.gcampax.github.com']
        favorite-apps = ['org.mozilla.firefox.desktop', 'org.mozilla.Thunderbird.desktop', 'org.gnome.Nautilus.desktop']


        # Enable location services for night light and other apps
        [org.gnome.system.location]
        enabled = true
      '';

      extraGSettingsOverridePackages = [
        # org.gnome.desktop
        pkgs.gsettings-desktop-schemas
        # org.gnome.settings-daemon
        pkgs.gnome-settings-daemon
        # org.gnome.shell
        pkgs.gnome-shell
        # org.gnome.mutter
        pkgs.mutter
      ];
    };
    displayManager.gdm.enable = true;
  };

  # Install GNOME Core apps which do not have a flatpak
  environment.systemPackages = [
    # TODO: could be in usage later?
    pkgs.gnome-disk-utility
    # gnome-console -> alacritty
    pkgs.nautilus
    # GNOME extensions app cannot be removed
    # https://github.com/NixOS/nixpkgs/issues/297847
    # So leave the app and the recommended extensions installed (not enabled)
    pkgs.gnome-shell-extensions
    # TODO: could be an independent store warehouse / bazaar etc
    pkgs.gnome-software
    # TODO: could be missioncenter or usage
    pkgs.gnome-system-monitor
    pkgs.gnome-tour
    pkgs.yelp
  ];

  networking.networkmanager.plugins =
    with pkgs; [
      networkmanager-fortisslvpn
      networkmanager-iodine
      networkmanager-l2tp
      networkmanager-openconnect
      networkmanager-openvpn
      networkmanager-sstp
      networkmanager-strongswan
      networkmanager-vpnc
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
      { appId = "org.gnome.font-viewer"; origin = "flathub-nix"; }
      { appId = "org.gnome.Loupe"; origin = "flathub-nix"; }
      { appId = "org.gnome.Logs"; origin = "flathub-nix"; }
      { appId = "org.gnome.Maps"; origin = "flathub-nix"; }
      # org.gnnome.Music -> Finamp
      { appId = "org.gnome.Papers"; origin = "flathub-nix"; }
      { appId = "org.gnome.SimpleScan"; origin = "flathub-nix"; }
      { appId = "org.gnome.Snapshot"; origin = "flathub-nix"; }
      { appId = "org.gnome.TextEditor"; origin = "flathub-nix"; }
      # org.gnome.Showtime -> VLC
      { appId = "org.gnome.Weather"; origin = "flathub-nix"; }
      # Extra GNOME apps
      { appId = "org.gnome.FileRoller"; origin = "flathub-nix"; }
      { appId = "org.gnome.NautilusPreviewer"; origin = "flathub-nix"; }
    ];

  # Setup default mime apps
  xdg.mime = {
    enable = true;
    defaultApplications = {
      # Web
      "application/xhtml+xml" = [ "org.mozilla.firefox.desktop" ];
      "text/html" = [ "org.mozilla.firefox.desktop" ];
      "x-scheme-handler/http" = [ "org.mozilla.firefox.desktop" ];
      "x-scheme-handler/https" = [ "org.mozilla.firefox.desktop" ];
      # Mail
      "x-scheme-handler/mailto" = [ "org.mozilla.Thunderbird.desktop" ];
      # Calendar
      "text/calendar" = [ "org.mozilla.Thunderbird.desktop" ];
      # Music
      "audio/x-vorbis+ogg" = [ "org.videolan.VLC.desktop" ];
      # FIXME: these don't work would need to do all possibles
      # "audio/*" = [ "org.videolan.VLC.desktop" ];
      "audio/flac" = [ "org.videolan.VLC.desktop" ];
      # Video
      "video/x-ogm+ogg" = [ "org.videolan.VLC.desktop" ];
      # "video/*" = [ "org.videolan.VLC.desktop" ];
      "video/mp4" = [ "org.videolan.VLC.desktop" ];
      # Photos
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      # "image/*" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      # Extra specifics
      #
      # Directories
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      # PDF
      "document/pdf" = [ "org.gnome.Papers.desktop" ];
      "text/markdown" = [ "org.gnome.TextEditor.desktop" ];
      "text/plain" = [ "org.gnome.TextEditor.desktop" ];
    };
  };
}
