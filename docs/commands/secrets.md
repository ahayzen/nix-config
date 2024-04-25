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
