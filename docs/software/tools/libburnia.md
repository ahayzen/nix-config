<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Libburnia

> Ensure that your user has permission to write to `/dev/sr0` (eg is in the `cdrom` group)

## Creating an ISO

```bash
nix-shell -p dvdisaster libisoburn

# Create the ISO
export SRC=./Archive
xorrisofs -V "ARCHIVE_2000" -J -joliet-long --modification-date=$(date +%Y%m%d%H%M%S%2N) -R -o output.iso $SRC
```

> If a file is larger than 4 GiB then use `-iso-level 3`

## Burning an ISO

```bash
nix-shell -p dvdisaster libisoburn

# Burn the ISO to disk (formatting to enable BD Defect Management)
xorrecord blank=format_overwrite dev=/dev/sr0 speed=4b output.iso -nopad -v

# Alternatively the following command can format with BD Defect Management disabled
# xorrecord blank=as_needed dev=/dev/sr0 speed=4b output.iso -v
```

> When using BD Defect Management xorrecord padding needs to be disabled for the ISO to fit

> When using BD Defect Management this writes at a slower (half) speed

## Finding disc info

```bash
nix-shell -p libisoburn

# For general info about the disc
xorriso -outdev /dev/sr0 -toc
```
