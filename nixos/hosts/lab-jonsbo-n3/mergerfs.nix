# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  fileSystems."/mnt/pool" = {
    depends = [
      "/mnt/data1"
    ];
    device = "/mnt/disk*";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=off"
      "category.create=mfs"
      "dropcacheonclose=false"
      "fsname=mergerfspool"
    ];
  };
}
