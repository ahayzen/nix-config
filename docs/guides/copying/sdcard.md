<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# SD Card

Use the [camera folder structure](../../data/camera.md).

## XMP Sidecar

Generate [XMP sidecar](../../formats/xmp.md) to ensure that Immich correctly picks the right date.

## Mount time offset

If the files are from a SD card which had an incorrect timestamp it is possible to use the following argument to mount

```console
-o time_offset=-360
```

This is also due to Linux considering SD cards / exFAT as UTC, using -360 is effectively UTC-6.

> This can be changed via Edit Mount Options in GNOME Disks by adding `time_offset=-360`