<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Dvdisaster

Dvdisaster can be used to transparently add parity data to the ISO.

There are different protections modes, but RS03 allows for augmenting data and multiple CPU cores.

## Add parity

```bash
nix-shell -p dvdisaster

# Embed parity info into the ISO
dvdisaster -i output.iso -mRS03 -x$(nproc) -c
```

## Verify parity

```bash
nix-shell -p dvdisaster

# Verify the disk
dvdisaster -d /dev/sr0 -s
```

## Redundency

It is recommended to use 20% redundancy with RS03, this means parity data is 16.7% of the total and data is 83.3%.

### Single layer

A dvdisaster generated image has 11826114 sectors (50 less than the disc) at a 2048 size.

So target less than 20.175G.

### Triple layer

A dvdisaster generated image has 47305560 sectors (200 less than the disc) at a 2048 size.

So target less than 80.702G.
