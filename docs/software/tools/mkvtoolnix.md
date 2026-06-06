<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# MKVToolNix

## GUI

Use [MKVToolNix](https://flathub.org/apps/org.bunkus.mkvtoolnix-gui) to adjust MKV metadata.

Eg if the audio tracks need reordering and changing of default.

> Note this can reorder change the segment order

## CLI

There are varios CLI tools available with the following command.

```console
$ nix-shell -p mkvtoolnix-cli
```

## Segement Order

Sometimes when editing metadata using MKVToolNix the segement order can change, resulting in tracks or tags near the end.

This can then cause players to becoming stuck with a black image when playing the video, such as Jellyfin on Android TV.

To identify the issue run `mkvinfo` and check if there are any tracks.
If there are no tracks then remux the video by running `mkvmerge -o out.mkv in.mkv`.

https://codeberg.org/mbunkus/mkvtoolnix/wiki/All-tracks-vanished-after-mkvpropedit%2C-the-header-or-chapter-editors