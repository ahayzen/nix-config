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
-o time_offset=180
```

THe following offsets could be used for different timezones

| Camera Timezone | `time_offset` |
|-----------------|---------------|
| EST (UTC+2)     | 120           |
| EEST (UTC+3)    | 180           |
| JST (UTC+9)     | 480           |

> Linux considers SD cards / exFAT as UTC so the Linux machine timezone does not matter only the camera

> This can be changed via Edit Mount Options in GNOME Disks by adding `time_offset=180`
