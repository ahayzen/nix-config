<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Jellyfin

Jellyfin allows for playing media from multiple devices

## Data

  - Read access to Music, Movies, Recordings, TV shows

## Backup

TODO

## Restore

TODO

## Configuration

  - Create an admin account and then user accounts
  - Libraries -> Libraries
    - Home Videos and Photos -> Recordings
    - Music
    - Movies
    - TV shows
  - Libraries -> Movies enable Automatically add to collection

### Intel Hardware Acceleration

On Intel use the following command to check for which codecs are supported,
then enable VA-API or QSV and ensure the relevant codecs are enabled

```sh
docker exec -it jellyfin /usr/lib/jellyfin-ffmpeg/vainfo
```

> This made 4K go from around 30fps to over 100fps on 12 year old hardware

https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#configure-with-linux-virtualization

  - Playback -> Transcoding
    - For Intel pick QuickSync or VAAPI
      - Check the support codecs and enable them
