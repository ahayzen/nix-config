# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    ./hardware.nix
  ];

  # OVH uses BIOS so we need to disable systemd-boot and use grub
  #
  # But we still allow for potentially using EFI boot in the future
  boot.loader = {
    # We need to disable so that efiInstallAsRemovable can be enabled
    # and we don't have an EFI mountpoint so install in the root
    efi = {
      canTouchEfiVariables = lib.mkForce false;
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
    # Specify the docker file we are using
    docker-compose-file = ./docker-compose.yml;

    hostName = "vps";
  };

  # Config files for caddy and wagtail
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    local-py_ahayzen-com = {
      file = ../../../secrets/local-py_ahayzen-com.age;
      # Set correct owner otherwise docker cannot read the file
      mode = "0600";
      owner = "unpriv";
      group = "unpriv";
    };
    local-py_yumekasaito-com = {
      file = ../../../secrets/local-py_yumekasaito-com.age;
      # Set correct owner otherwise docker cannot read the file
      mode = "0600";
      owner = "unpriv";
      group = "unpriv";
    };
  };

  environment.etc = {
    "ahayzen.com/local.1.py".
    source =
      if config.ahayzen.testing
      then ./local.vm.py
      else config.age.secrets.local-py_ahayzen-com.path;
    "yumekasaito.com/local.1.py".
    source =
      if config.ahayzen.testing
      then ./local.vm.py
      else config.age.secrets.local-py_yumekasaito-com.path;
    "caddy/Caddyfile.1".source =
      if config.ahayzen.testing
      then ./Caddyfile.vm
      else ./Caddyfile;
  };

  # Ports to allow for SSH proxies
  networking.firewall.allowedTCPPorts = [
    # Audio
    9881
    # Video
    9888
    # VPN
    9194
    # Bitwarden
    9821
    # WebDAV
    9506
  ];

  # Allow for SSH proxies to bind on the host rather than loopback
  services.openssh.settings.GatewayPorts = "clientspecified";

  # Reload if static files change
  #
  # Note agenix files are not possible and will need the version bumping
  # which causes the hash of the docker-compose file to change.
  systemd.services."docker-compose-runner".reloadTriggers = [
    (builtins.hashFile "sha256" config.environment.etc."caddy/Caddyfile.1".source)
  ];

  # Increase disk size for build VM
  virtualisation.vmVariant.virtualisation.diskSize = 2 * 1024;

  # Create a tunneller user for SSH tunnels
  #
  # TODO: investigate using something like https://github.com/rapiz1/rathole
  users.users.tunneller = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [ config.ahayzen.publicKeys.user.synology-nas-tunneller ];
  };
}
