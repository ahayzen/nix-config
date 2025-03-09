# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

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
}
