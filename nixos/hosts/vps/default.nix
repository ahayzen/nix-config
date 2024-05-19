# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, inputs, lib, options, ... }:
{
  imports = [
    ./disko-config.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    ./hardware.nix
  ];

  ahayzen = {
    # Specify the docker file we are using
    docker-compose-file = ./docker-compose.yml;

    hostName = "vps";

    # Enable testing for now until DNS points to the correct place
    # and to see how NixOS performs
    testing = true;
  };

  # Config files for caddy and wagtail
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    local-py_ahayzen-com.file = ../../../secrets/local-py_ahayzen-com.age;
    local-py_yumekasaito-com.file = ../../../secrets/local-py_yumekasaito-com.age;
  };
  environment.etc = {
    "ahayzen.com/local.1.py".source =
      if config.ahayzen.testing
      then ./local.vm.py
      else config.age.secrets.local-py_ahayzen-com.path;
    "yumekasaito.com/local.1.py".source =
      if config.ahayzen.testing
      then ./local.vm.py
      else config.age.secrets.local-py_yumekasaito-com.path;
    "caddy/Caddyfile.1".source =
      if config.ahayzen.testing
      then ./Caddyfile.vm
      else ./Caddyfile;
  };

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
