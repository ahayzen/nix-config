<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# XMP

## GUI

Use [digiKam](https://flathub.org/apps/org.kde.digikam) to edit meta data.

### Adjusting exif dates

Using digiKam highlight the media and select Tools -> Adjust Time Date to update the creation date for immich.

> Use Timestamp adjustments interval if time is unknown to create an offset

## CLI

```console
$ nix-shell -p exiftool
```

### Creating XMP files

Using digiKam navigate to Settings -> Configure Digikam -> Metadata page and choose `Write to XMP sidecar only`.

Now adjust the dates as before, but a separate .xmp sidecar file will appear.

> Immich sometimes reads exif tags that cannot be changed easily, so using a XMP sidecar file to override can resolve this

To manually create XMP files for multiple sources and be explicit about their timezone use the following command (note this also has a -3min time shift).

```console
exiftool -ext MP4 -tagsfromfile @ -srcfile %d%f.%e.xmp -api QuickTimeUTC "-alldates>alldates" -globaltimeshift "-0:0:0 0:3:0" -r .
```

> This is useful with GoPro footage where there is a timezone field but the creation date is also in the timezone and not UTC so immich can add them together