<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# `nixos-anywhere`

Use `nixos-anywhere` to install this flake on an existing machine Linux machine.

On the existing machine extract the existing ssh host key.

```console
$ cat /etc/ssh/ssh_host_ed25519_key.pub
```

Add this to the relevent host in [keys.nix](../secrets/key.nix) and [rekey](./secrets.md#rekey). This allows for access to secrets during deployment and automatic upgrades.

> Test that the flake builds using a vm with the following command
>
> ```console
> $ nix run github:nix-community/nixos-anywhere -- --copy-host-keys --flake .#machine-name --vm-test
> ```

Then run `nixos-anywhere` with the target host.

```console
$ nix run github:nix-community/nixos-anywhere -- --copy-host-keys --flake .#machine-name user@host
```

# `nixos-rebuild`

For rebuilding remote systems

```console
$ NIX_SSHOPTS="-o RequestTTY=force" nixos-rebuild switch --build-host user@host --target-host user@host --use-remote-sudo --flake .#machine-name
```

For rebuilding local systems

```console
$ nixos-rebuild switch --flake .#machine-name
```

# `nixos-generate-config` on foreign host

Use the following to install the Nix daemon and retrieve a `hardware-configuration.nix` file.

```console
$ sudo su
# sh <(curl -L https://nixos.org/nix/install) --daemon

$ sudo su
# nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config ]"
# nixos-generate-config --no-filesystems --root /mnt
# cat /mnt/etc/nixos/hardware-configuration.nix
```
