# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, pkgs, ... }:
{
  services.snapraid = {
    enable = true;

    contentFiles = [
      "/var/lib/snapraid/snapraid.content"
      "/mnt/data1/snapraid.content"
      "/mnt/parity1/snapraid.content"
    ];

    dataDisks = {
      # Note order is important for parity
      data1 = "/mnt/data1";
    };

    parityFiles = [
      "/mnt/parity1/snapraid.parity"
    ];

    # Check 1% of the data daily
    scrub = {
      plan = 1;
    };
    sync.interval = "07:30";
  };

  # Use --pre-hash option as we do not have ECC memory
  systemd.services.snapraid-sync.serviceConfig.ExecStart = lib.mkForce "${pkgs.snapraid}/bin/snapraid --pre-hash sync";

  # TODO: call `getfacl --recursive /mnt/disk1 > /mnt/disk1/disk1.permissions`
  # note restore with `setfacl --restore=/mnt/disk1/disk1.permissions`

  # Add a condition to nixos-upgrade
  # This then skips nixos-upgrade if snapraid is running
  systemd.services."nixos-upgrade" = {
    serviceConfig = {
      ExecCondition = [
        "/bin/sh -c '[[ $( ${pkgs.systemd}/bin/systemctl is-active snapraid-scrub.service ) != activ* ]]'"
        "/bin/sh -c '[[ $( ${pkgs.systemd}/bin/systemctl is-active snapraid-sync.service ) != activ* ]]'"
      ];
    };
  };
}
