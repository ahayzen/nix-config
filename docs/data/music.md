<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Music

How to add and convert music into the storage.

## Folder structure

There are three file types to consider

* Track in FLAC and metadata
* Lyrics in LRC
* Album art in JPG

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

## Meta data

Use [Kid3](https://flathub.org/apps/org.kde.kid3) to edit meta data, ensure that

* Date field is set
* Disc Number is correct if there are multiple discs

## Lyrics

Use [LRCGet](https://github.com/tranxuanthang/lrcget) to download lyrics.

## FLAC Corruption

Test if a flac file is corrupt.

```sh
flac -t *.flac
```

Fix a corrupt flac file

```sh
flac --verify --compression-level-0 --decode-through-errors --preserve-modtime -o out.flac in.flac
```
