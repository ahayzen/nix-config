<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Test in a VM

## `nixos-build`

```console
$ nix-shell -p nixos-rebuild
$ nixos-rebuild build-vm --flake .#<machine>
```

## `nix build`

```console
$ nix build .#nixosConfigurations.<machine>.config.system.build.vm
```

## Start VM

```console
$ export QEMU_NET_OPTS="hostfwd=tcp::2221-:22,hostfwd=tcp::2280-:80"
$ result/bin/run-<machine>-vm
```

## Enter VM

```console
$ ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no admin@localhost -p 2221
```

## Flake check

We need the sandbox disabled as we need network access

```console
$ nix flake --option sandbox false check -L --show-trace
```
