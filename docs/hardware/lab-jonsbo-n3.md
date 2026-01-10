<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Jonsbo N3 lab

This is the homelab using a Jonsbo N3 case.

## Specs

| Item | Model | Price |
|------|-------|-------|
| CPU | Intel i5-14500 | £230 |
| Mobo | Asrock Z790M-ITX WiFi | £220 |
| RAM | Crucial 32GB DDR5 | £88 |
| PSU | Corsair SF750 | £155 |
| SSD | WD Red SN700 1TB | £80 |
| HDD | 2x Toshiba N300 8TB | 2x £185 |
| HBA | LSI SAS 9211-8i | £30 |
| Cooling | Noctua NH-D9L, 2x NF-A8, NF-A4x10, 2x Jonsbo 100mm | £50, 2x £17, £18 |
| Case | Jonsbo N3 | £140 |
| Cables | 2x SFF-8087 to 4x SATA (50cm), Molex extension (30cm) | 2x £9, £2.5 |

Effective total was ~£1070 + £370 for disks.

For equivalent prebuilt systems there are were similar options that were
8-bay tower systems that are small and x86.

  - £1000, Synology DS1821+, AMD 4 core V1500B, 4GB RAM, 26W idle no disks
  - £1600, Synology DS1823xs+, AMD 4 core V1780B, 8GB RAM, 28W idle no disks
  - £1200, QNAP TS-873A, AMD 4 core V1500B, 8GB RAM, 26W idle no disks
  - £2550, QNAP TVS-h874-i5-32G, Intel i5-12400, 32GB RAM, 58W idle no disks
  - £3200, QNAP TVS-h874T-i7-32G, Intel i7 12th gen, 32GB RAM, 62W idle no disks

> Note the i5 QNAP is very similar to this build, but with a much higher price, power usage, and without any HDD or NVMe drives

## Services

  - ActualBudget
  - Audiobookshelf
  - Bookstack
  - BitWarden
  - Immich
  - Jellyfin
  - Paperless
  - Restic
  - SFTPGo
  - Vikunja

## Backup

TODO

## Restore

TODO

## Setup

  - [x] Memtest
  - [x] badblocks
  - [x] Thermals
  - [x] Power usage

### BIOS

  - [x] Disable Secure Boot

## Power

|  | Idle Power |
|--|------------|
| BIOS baseline | 52W |
| NixOS baseline | 35W |
| Enable package C state | 33W |
| With 2x HDD | 45W |
| Enable ASPM | increased power? (see below) |
| Disable audio | minor diff <1W |
| Disable 2.5 GBe | minor diff <1W |

> A mixture of Intel 12/13/14th gen, HBA, other devices the kernel doesn't enable ASPM for results
in there not being much of a saving. Without the HBA it is possible to reach 22W.
Note that we are idling lower or similar to equivalent Synology and QNAP devices.

Under stress test loads of a component

| Load | Power |
|------|-------|
| CPU | 145W (turbo), 125W |
| HDD | 55W |

## Thermals

| Device | Temp |
|--------|------|
| CPU | 25C - 45C |
| HDD | 20C - 31C |

> Ambient of around 18C

## Expansion

Some possible expansion or improvements

  - 1x RAM slot
  - 2.5" internal SATA SSD
  - 1x M2 slot
  - 6x 3.5" HDD
  - Bifurcation of PCIe x16 or M2 to PCIe adaptor
    - 10GBe network card
    - Another HBA
    - GPU
  - Replace HBA with 8i8e for 8 external ports and connect to external DAS
  - Cable mod for power cables to SAS backplane
  - Noctua 92mm fans to replace Jonsbo
