<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Music

How to add and convert music into the storage.

There are three file types to consider

* Track in FLAC and metadata
* Lyrics in LRC
* Album art in JPG

## Folder structure

For a number album this means the following

```
/music
  /<artist>
    /<album>
      /NN <song>.flac
      /NN <song.lrc
      /Folder.jpg
```

If the album has multiple discs then add this to the file name

```
/music
  /<artist>
    /<album>
      /Disc NN - NN <song>.flac
      /Disc NN - NN <song.lrc
      /Folder.jpg
```
