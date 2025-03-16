# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{
  disko.devices = {
    disk = {
      #
      # OS drive
      #
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_Red_SN700_1000GB_24340A800209";
        content = {
          type = "gpt";
          partitions = {
            biosgrub = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "umask=0077" ];
              };
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
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
          };
        };
      };

      #
      # Parity disks
      #
      parity1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWG480_64T0A10MFA3H";
        content = {
          type = "gpt";
          partitions = {
            parity = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/parity1";
              };
            };
          };
        };
      };

      #
      # Data disks
      #
      data1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWG480_54H0A00QFA3H";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/data1";
              };
            };
          };
        };
      };
    };
  };
}
