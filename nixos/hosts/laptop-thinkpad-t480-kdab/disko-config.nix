# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  # TODO: LUKS encryption
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            biosgrub = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            boot = {
              size = "1024M";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "+100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
