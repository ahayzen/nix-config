<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Create or edit

```console
$ cd secrets/
$ nix run github:ryantm/agenix -- -e password_andrew.age
```

> Use `EDITOR="nano --nonewlines"` to prevent automatic new lines being added to password files

# Rekey

```console
$ cd secrets/
$ nix run github:ryantm/agenix -- --rekey
```

# Generating a SSH key for a user

```console
ssh-keygen -f ~/.ssh/id_ed25519 -t ed25519
```

Update a password using

```console
ssh-keygen -f ~/.ssh/id_ed25519 -p
```
