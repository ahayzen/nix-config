<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Archive

For cold-storage or archiving there are a few options

  * Using an offline HDD
  * Using Blu-ray disks

## Blu-ray

We need to do the following steps

  * Create an ISO from files
  * Embedded parity info into the ISO
  * Burn the ISO to a disk

> Aim for around 20-30% of parity data

Using libisoburn specific commands

```bash
nix-shell -p dvdisaster libisoburn

# Create the ISO
xorrisofs -V "ARCHIVE_2000" -J -R -o output.iso /input/folder

# Embed parity info into the ISO
dvdisaster -i output.iso -mRS03 -x$(nproc) -c

# Burn the ISO to disk (formatting to enable BD Defect Management)
xorrecord blank=format_overwrite dev=/dev/sr0 speed=4b output.iso
```
