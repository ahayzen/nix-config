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

```
VPS
    \
PC  -- NAS -- Offsite
    /     \
Phone       Cold storage
```

## Schedule

### Daily / Constant

  * Backup NAS to offsite
  * Phone sync with NAS
  * PC sync with NAS

### Weekly

  * Backup VPSs to NAS

### Monthly

  * Verify 10% of offsite backup
  * Verify 50% of local backup
  * Backup to local cold storage

## Quarterly

  * Restore selected file from offsite and cold storage

# Sqlite backup

```console
$ sqlite3 data/db.sqlite3 ".backup '/path/to/backups/db-$(date '+%Y%m%d-%H%M').sqlite3'"
```
