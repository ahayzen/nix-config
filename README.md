<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Andrew's Nix Configuration

Aims for machines and services configured

  * Do one thing and do it well
  * Minimal and automated maintainence
  * Official sources are preferred
  * Each service should be independant

The concept for both desktop and headless has three layers

  * NixOS for hardware provisioning and system services
  * Containers to create isolated environments
  * Apps and services running in containers

## Desktop

```
|-------------------------------|
|           NixOS Base          |
|-------------------------------|
| Flatpak | Distrobox | Podman  |
|-------------------------------|
|   Apps  |  Mutable  |  Dev    |
|-------------------------------|
```

## Headless (NAS / Server)

```
|-------------------------------|
|           NixOS Base          |
|-------------------------------|
|         Docker Compose        |
|-------------------------------|
|            Services           |
|-------------------------------|
```
