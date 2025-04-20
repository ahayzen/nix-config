<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Immich

Immich manages photos and videos from cameras and allows for upload from mobile devices.

TODO: reasons for choosing immich

## Data

  - Read access to Camera
  - Read and Write access to Photostream

## Backup

TODO

## Restore

TODO

## Configuration

  - Create an admin account and then user accounts
  - Add Camera as an external library for the admin account
  - Set transcode video concurrency to two under jobs

For low powered hardware consider

  - Allow HEVC otherwise lots of videos are transcoded.
    - Settings -> Video Transcoding Settings -> Transcode Policy -> Accepted video codecs -> HEVC

## Alternatives

  - Photoprism + Photosync
