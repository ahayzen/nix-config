# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ modulesPath, ... }:
{
  # TODO: instead make this file from nixos-generate?
  # https://nix-community.github.io/nixos-anywhere/quickstart.html
  # https://github.com/nix-community/nixos-images#kexec-tarballs
  # nixos-generate-config --no-filesystems --root /mnt
  imports = [
    # Profiles from Nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Ensure that we have support for the nvme SSD
  boot.initrd.kernelModules = [ "nvme" ];
}
