<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# FLAC

Test if a flac file is corrupt.

```sh
flac -t *.flac
```

> If the metadata is corrupt or missing padding it will report OK, but could fail to play on ExoPlayer (Jellyfin Android)

Fix a corrupt flac file

```sh
flac --verify --compression-level-5 --decode-through-errors --preserve-modtime -o out.flac in.flac
```

> Compression level 5 uses the same buffer size and rates that Sound Juicer produces
