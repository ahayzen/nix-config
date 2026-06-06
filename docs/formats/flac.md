<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# FLAC

Test if a flac file is corrupt.

```sh
flac -t *.flac
```

Fix a corrupt flac file

```sh
flac --verify --compression-level-0 --decode-through-errors --preserve-modtime -o out.flac in.flac
```