# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, pkgs, ... }:
{
  services.snapraid = {
    enable = true;

    contentFiles = [
      "/var/lib/snapraid.content"
      "/mnt/data1/snapraid.data1.content"
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
      interval = "08:30";
      plan = 1;
    };
    sync.interval = "07:30";
  };

  systemd.services.snapraid-sync.serviceConfig.ExecStart = lib.mkForce [
    # TODO: split the facl and fattr into separate service/timer
    # Snapraid does not store file permissions so store in file
    #
    # Note restore with `setfacl --restore=/mnt/data1/snapraid.data1.facl`
    # "${pkgs.acl}/bin/getfacl --absolute-names --recursive /mnt/data1 > /mnt/data1/snapraid.data1.facl"
    # Snapraid does not store file extended attribute so store in file
    #
    # Note restore with `setfattr --restore=/mnt/data1/snapraid.data1.fattr`
    # "${pkgs.attr}/bin/getfattr --absolute-names --recursive /mnt/data1 > /mnt/data1/snapraid.data1.fattr"
    # Use --pre-hash option to ensure integrity as we do not have ECC memory
    "${pkgs.snapraid}/bin/snapraid --pre-hash sync"
  ];

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
