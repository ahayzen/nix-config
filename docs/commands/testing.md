
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