<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Backup

  * 3-2-1 backup
  * Automated
  * Encrypted offsite
  * Verifiable

## Locations

  * VPSs
  * PCs
  * Phones
  * NAS
  * Offsite
  * Cold storage

## Flow

From left to right

```plain
VPS         Snapshot
    \     /
PC  -- NAS -- Offsite
    /     \
Phone       Cold storage
```

## Schedule

  * Devices sync as events occur to NAS
  * Daily sync of VPS to NAS
  * Daily backup of NAS to Snapshot and Offsite
  * Daily verify of subset of backups
