<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Camera

How to add and convert photos into the storage.

## Folder structure

There are generally two file types to consider

  * Photo in JPG
  * Video in MP4

```
/camera
  /Device
    /YYYY
      /Topic
        /image1.jpg
  /Unknown
    /YYYY
      /Topic
        /image1.jpg
```

## Meta data

Use [digiKam](https://flathub.org/apps/org.kde.digikam) to edit meta data.

Highlight the media and select Tools -> Adjust Time Date to update the creation date for immich.

> Use Timestamp adjustments interval if time is unknown to create an offset

If the files are from a SD card which had an incorrect timestamp it is possible to use the following argument to mount

```console
-o time_offset=-360
```
