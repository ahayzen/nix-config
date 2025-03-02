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
  - Playback -> Transcoding
    - For Intel pick QuickSync or VAAPI
      - Check the support codecs and enable them
        - Eg a command such as `sudo /usr/lib/jellyfin-ffmpeg/vainfo --display drm --device /dev/dri/renderD128`
        - [https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#configure-on-linux-host]
    - See docs for more info [https://jellyfin.org/docs/general/administration/hardware-acceleration]
