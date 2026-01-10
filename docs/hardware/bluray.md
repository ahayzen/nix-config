<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Blu-ray

Can be used as a cheap offline WORM backup of data, see [Archive](../data/archive.md).

Multiple sizes are available of 25G, 50G, 100G, 128G.

## Disk Info

```console
nix-shell -p libisoburn

# For general info about the disc
xorriso -outdev /dev/sr0 -toc
```

| Disc | Quantity | ID | Source | Price | Price / TB |
|------|----------|----|--------|-------|------------|
| Sony BD-R Blue | 10x 25G | `CMCMAG/BA3/0, CMC Magnetics Corporation` | Donkey Japan | ¥1650 | £34.73 |
| Verbatim BD-R Rainbow | 10x 25G | `CMCMAG/BA5/0, CMC Magnetics Corporation` | Donkey Japan | ¥800 | £16.84 |
| Verbatim BD-XL Purple | 3x 100G | `VERBAT/IMk/0, Mitsubishi Chemical Media Co., Ltd.` | Donkey Japan | ¥1958 | £34.33 |

> Disc IDs can be looked up at [https://blu-raydisc.info/licensee-list/discmanuid-licenseelist.php]
