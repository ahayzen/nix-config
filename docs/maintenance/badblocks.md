<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Badblocks

Download the script from [https://github.com/Spearfoot/disk-burnin-and-testing]

```console
nix-shell -p e2fsprogs smartmontools

sudo ./disk-burnin.sh -f -b 4096 -o ~/burn-in-logs /dev/sda
```

> Note this can take a long time so run inside zellij

## Monitor disk temps

```console
nix-shell -p hddtemp

sudo watch -n 60 hddtemp -q /dev/sd*
```
