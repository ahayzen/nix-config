# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

# Test that a desktop machine can boot

(import ./lib.nix) {
  name = "desktop-test";
  nodes = {
    desktop = { self, inputs, pkgs, outputs, ... }: {
      imports =
        [
          self.nixosModules.desktopSystem
          # TODO: update to user changes later
          ../nixos/users/andrew
          {
            home-manager.extraSpecialArgs = { inherit inputs outputs; };
            home-manager.users.andrew = self.homeManagerModules.andrew;
          }
        ];

      ahayzen = {
        testing = true;

        hostName = "desktop";
      };

      environment.etc."ahayzen.com/expected/gnome".source = ./expected/gnome;

      # Force no date or seconds in the clock for consistent screenshots
      # and enable Do Not Disturb to avoid notifications
      services.desktopManager.gnome = {
        extraGSettingsOverrides = ''
          [org.gnome.desktop.interface]
          clock-show-date = false
          clock-show-seconds = false

          [org.gnome.desktop.notifications]
          show-banners = false
        '';

        extraGSettingsOverridePackages = [
          # org.gnome.desktop
          pkgs.gsettings-desktop-schemas
        ];
      };

      # Set password for user to login
      users.users.andrew = {
        password = "test";
        uid = 2000;
      };

      virtualisation = {
        cores = 2;
        memorySize = 2 * 1024;
        useEFIBoot = true;
      };
    };
  };

  extraPythonPackages = p: [ p.numpy p.opencv4 ];

  testScript = { nodes, ... }:
    let
      gdm = nodes.desktop.users.users.gdm;
    in
    ''
      import base64
      import cv2
      import numpy as np
      import os

      start_all()

      # From https://stackoverflow.com/a/51289984
      def compare_images(filename):
        path1 = os.path.join(desktop.out_dir, f"{filename}.png")

        desktopPath2 = f"/etc/ahayzen.com/expected/gnome/{filename}.png"
        desktop.copy_from_vm(desktopPath2, "expected")
        path2 = os.path.join(desktop.out_dir, "expected", f"{filename}.png")

        # Print base64 output of image so we can download
        with open(path1, "rb") as f:
          data = base64.encodebytes(f.read())
          print(f"Comparing image {path1}: {data}")

        # Load the images
        img1 = cv2.imread(path1, 0)
        img2 = cv2.imread(path2, 0)

        # Check shape is the same
        if img1.shape != img2.shape:
          return 0.0

        # Absolute difference
        res = cv2.absdiff(img1, img2)

        # Convert to an integer type
        res = res.astype(np.uint8)

        # Determine percetange difference
        return (np.count_nonzero(res) * 100)/ res.size

      #
      # Test that the desktop machine boots
      #

      with subtest("Ensure that the system booted"):
        desktop.sleep(1)
        desktop.send_key("ctrl-alt-f7")
        desktop.wait_for_unit("default.target", timeout=120)

      with subtest("Ensure that GDM is correct"):
        desktop.wait_for_unit("display-manager.service", timeout=120)
        desktop.wait_for_unit("graphical.target", timeout=30)
        # desktop.wait_for_file("/run/user/${toString gdm.uid}/wayland-0", timeout=30)
        desktop.sleep(15)

        # Compare the screenshot
        desktop.screenshot("login")
        diff = compare_images("login")
        assert diff < 0.5, f"Login image was different by {diff}%, more than 0.5%"

      with subtest("Ensure that we can login"):
        desktop.send_chars("\n")
        desktop.sleep(1)
        desktop.send_chars("test\n", delay=0.2)
        desktop.sleep(5)

      with subtest("Ensure that desktop is reached"):
        # wait for the wayland server
        # machine.wait_for_file("/run/user/2000/wayland-0")
        # wait for alice to be logged in
        desktop.wait_for_unit("default.target", "andrew")
        desktop.sleep(5)
        # Wait long enough for GNOME Shell to login
        desktop.wait_for_unit("graphical-session.target", "andrew", timeout=120)
        # Wait for any initial setup
        desktop.sleep(15)

        # Compare the screenshot
        desktop.screenshot("desktop")
        diff = compare_images("desktop")
        assert diff < 0.5, f"Desktop image was different by {diff}%, more than 0.5%"

      with subtest("Dismiss initial setup"):
        # Click skip
        desktop.send_chars("\n")
        desktop.sleep(1)

        # Compare the screenshot
        desktop.screenshot("activities")
        diff = compare_images("activities")
        assert diff < 0.5, f"Activities image was different by {diff}%, more than 0.5%"

      with subtest("Open alacritty (checks home-manager themes)"):
        # Type alacritty and launch it
        desktop.send_chars("alacritty", delay=0.2)
        desktop.sleep(3)
        desktop.send_chars("\n")
        desktop.sleep(3)

        # Ensure that our keybinding works
        #
        # Also ensures that window size is consistent
        desktop.send_key("f11")
        desktop.sleep(3)

        # Compare the screenshot
        desktop.screenshot("alacritty")
        diff = compare_images("alacritty")
        assert diff < 0.5, f"Alacritty image was different by {diff}%, more than 0.5%"

      with subtest("General metrics"):
        print(desktop.succeed("cat /etc/hosts"))
        print(desktop.succeed("ps auxf"))
        print(desktop.succeed("free -h"))
        print(desktop.succeed("df -h"))
    '';
}
