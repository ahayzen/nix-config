<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Shows

How to add and convert TV shows into the storage.

## Folder structure

There are three file types to consider

* TV show in MKV or MP4 + SRT
* Meta data in NFO
* Cover image in JPG

For a normal TV shows this means the following

```
/shows
  /My Show (YYYY)
    /My Show (YYYY).imdb
    /folder.jpg
    /tvshow.nfo
    /Season 00
      /My Show Special.mp4
    /Season 01
      /My Show S01E01.mp4
      /My Show S01E01.nfo
      /My Show S01E02-E03.mp4
      /My Show S01E02-E03.srt
```

> Specials that are not part of the seasons go into Season 00