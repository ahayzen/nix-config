<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# All

| Timer | Frequency | Purpose |
|-------|-----------|---------|
| `nix-gc` | `07:30` | Garbage collect |
| `nix-optimise` | `11:30` | Optimise store |
| `nixos-upgrade` | `hourly` | Update the system |


# Headless

| Timer | Frequency | Purpose |
|-------|-----------|---------|
| `backup-machines` | `22:15` | Pull snapshot of machines |
| `virtualisation.docker.autoPrune.enable` | `13:30` | Clean old containers |

> TODO: add various machine specific timers for db snapshots of containers and other tasks

Upgrades are on the hour, tasks not depending on docker are at :15 or :45, tasks depending on docker
are at :30 to try and wait for nixos-upgrade to complete. All times are every 3 hours offset by 1hr.

  * nixos-upgrade - *:00
  * db snapshots - 22:15
  * rsync snapshot - 22:45
  * restic backup - 01:30
  * restic check - 04:30
