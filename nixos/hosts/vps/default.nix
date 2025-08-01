# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    ./hardware.nix
    # Include services
    #
    # Note that caddy should be first as other depend on it
    ./caddy
    ./glances
    ./hayzen-uk
    ./homepage
    ./ntfy
    ./rathole
    ./wagtail-ahayzen
    ./wagtail-yumekasaito
  ];

  # OVH uses BIOS so we need to disable systemd-boot and use grub
  #
  # But we still allow for potentially using EFI boot in the future
  boot.loader = {
    # We need to disable so that efiInstallAsRemovable can be enabled
    # and we don't have an EFI mountpoint so install in the root
    efi = {
      canTouchEfiVariables = lib.mkForce false;
      efiSysMountPoint = lib.mkForce "/boot";
    };

    grub = {
      enable = true;
      configurationLimit = 10;
      # disko automatically adds devices that have a EF02 partition
      # devices = [ "/dev/sda" ];
      efiSupport = true;
      # We need to enable this as we are currently booted in BIOS
      efiInstallAsRemovable = true;
      splashImage = null;
    };
    systemd-boot.enable = lib.mkForce false;
  };

  ahayzen = {
    docker-compose-files = [ ./compose.vps.yml ];
    hostName = "vps";
  };

  # We do not need avahi on a VPS
  services.avahi.enable = lib.mkForce false;

  # There is no SMART support on a VPS
  services.smartd.enable = lib.mkForce false;

  # Allow lab to login so that backups can occur
  users.users.headless.openssh.authorizedKeys.keys = [ config.ahayzen.publicKeys.host.lab-jonsbo-n3 ];

  # Allow synology to login to unpriv for ssh tunnel to VPN as fallback
  users.users.unpriv.openssh.authorizedKeys.keys = [ config.ahayzen.publicKeys.user.diskstation-forwarder ];

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 2 * 1024;
}
