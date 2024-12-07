<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Test with flake check

We need the sandbox disabled as we need network access

```console
$ nix flake --option sandbox false check --max-jobs 1 --print-build-logs --show-trace
```

## /tmp on tmpfs

The state of the VM is stored in the `TMPDIR`, so if /tmp is on tmpfs your VM
storage will use large amounts of memory.

We can override the nix-daemon to have use a directory that is not tmpfs.

```bash
# Or on NixOS
# systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp/nix-daemon";

sudo mkdir -p /etc/systemd/system/nix-daemon.service.d
sudo mkdir -p /var/tmp/nix-daemon

sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf <<EOF
[Service]
Environment=TMPDIR=/var/tmp/nix-daemon
EOF

sudo systemctl daemon-reload
sudo systemctl restart nix-daemon
```

# Test in a VM

Ensure that you add the following snippet to the configuration of the machine you want to test in a VM.

```nix
{
    ahayzen.testing = true;
}
```

> Note that if you are testing http update any `Caddyfile.vm` to use `http://localhost`
> rather than `http://mydomain.com` to access locally.

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
$ export QEMU_NET_OPTS="hostfwd=tcp::2221-:8022,hostfwd=tcp::2280-:80"
$ result/bin/run-<machine>-vm
```

Use `-m SIZE` to increase the memory size.

## Enter VM

```console
$ ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no admin@localhost -p 2221
```
