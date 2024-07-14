<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Accessing a chroot of the system

With a live image of a NixOS release.

Mount the root file system and the boot partition. (note you could use `/dev/disk/by-partlabel` too)

```bash
sudo mount /dev/mapper/pool-root /mnt
sudo mount /dev/sda1 /mnt/boot
```

Bind mount devices we need from the host

```bash
sudo mount --rbind /dev /mnt/dev
sudo mount --rbind /proc /mnt/proc
sudo mount --rbind /sys /mnt/sys
```

Now a chroot should work and normal Nix commands should be possible.

```bash
sudo chroot /mnt
```

# Reinstall the boot loader

Find the profile you want to install from in `/mnt/nix/var/nix/profiles`, then run the following command.

```bash
NIXOS_INSTALL_BOOTLOADER=1 chroot /mnt /nix/var/nix/profiles/system-NNN-link/bin/switch-to-configuration boot
```

# Repairing a corrupted vfat partition

Find the corrupt partition and then run the following.

```bash
sudo dosfsck -w -r -l -a -v -t /dev/sda1
```
