<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# All

| Timer | Frequency | Purpose |
|-------|-----------|---------|
| `nix-gc` | `daily` | Garbage collect |
| `nix-optimise` | `daily` | Optimise store |
| `nixos-upgrade` | `hourly` | Update the system |


# Headless

| Timer | Frequency | Purpose |
|-------|-----------|---------|
| `docker-compose-upgrade` | `hourly` | Update containers |
| `virtualisation.docker.autoPrune.enable` | `daily` | Clean old containers |
