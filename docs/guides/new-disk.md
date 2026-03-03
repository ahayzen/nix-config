<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# New disk

Process for adding a new disk to the pool.

  * Run badblocks burn in
  * Manually format the disk using gpt partition table
  * Add disk to disko config
  * Add to snapraid configuration
  * Reboot system
  * Optionally run mergerfs balance

Possible format command

```console
nix-shell -p parted

sudo parted /dev/sdX mklabel gpt
sudo parted -a opt /dev/sdX mkpart disk-data1-data xfs 0% 100%
sudo mkfs.xfs /dev/sdX1
```

Possible mergerfs command
  
```console
mergerfs.balance -s 1G -e snapraid.data1.content -e snapraid.data1.facl -e snapraid.data1.fattr  /mnt/pool 
```
