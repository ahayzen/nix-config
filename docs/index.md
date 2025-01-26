<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Docs

````
Configuration
  - machine
    - app
    - bios
    - specs
  - services
Data
  - camera
  - dvd
  - music
  - movies
  - tv shows

Maintenance
  - backup
  - deploy
  - restore
  - health
  - wipe

Recovery
  - 2FA
  - LUKS
  - Lost (what needs wiping/logging out)
  - Services
````

TODO: move into data/backup page

| Failure | Live | Snapshot | Offsite | Cold |
|---------|------|----------|---------|------|
| Disk | X | X | - | - |
| Flake Compromise | X | X | X | - |
| Fire | X | X | - | X |
| NixOS | X | X | - | - |
| Restic | - | X | X | - |
| Power Surge | - | - | X | X |
| XFS | X | X | - | - |

> Assuming that Cold storage uses exFAT/ext4 and rsync
