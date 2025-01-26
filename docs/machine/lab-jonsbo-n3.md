<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Jonsbo N3 lab

This is the homelab using a Jonsbo N3 case.

## Specs

| Item | Model |
|------|-------|
| CPU | Intel i5-14500 |
| Mobo | Asrock Z790M-ITX WiFi |
| RAM | Crucial 32GB DDR5 |
| PSU | Corsair SF750 |
| SSD | WD Red SN700 1TB |
| HDD | 2x Toshiba N300 8TB |
| HBA | LSI SAS 9211-8i |
| Cooling | Noctua NH-D9L, 2x NF-A8, NF-A4x10, 2x Jonsbo 100mm |

## Services

  - ActualBudget
  - Audiobookshelf
  - BitWarden
  - Immich
  - Jellyfin
  - Joplin
  - Restic
  - SFTPGo

## Backup

TODO

## Restore

TODO

## Setup

  - [ ] Memtest
  - [ ] badblocks
  - [ ] Thermals
  - [ ] Power usage

### BIOS

  - [ ] Disable Secure Boot

Power management changes

|  | Idle Power |
|--|------------|
| BIOS baseline | 52W |
| NixOS baseline | - |
| Enable package C state | - |
| Enable ASPM | - |
| Disable audio | - |
| Disable 2.5 GBe | - |

### Flashing LSI HBA

TODO
