<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Jellyfin

## Hardware acceleration

On Intel use the following command to check for which codecs are supported,
then enable VA-API or QSV and ensure the relevant codecs are enabled

```sh
docker exec -it jellyfin /usr/lib/jellyfin-ffmpeg/vainfo
```

> This made 4K go from around 30fps to over 100fps on 12 year old hardware

https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#configure-with-linux-virtualization

## Movies

Folder structure

```
Movies
- My Movie (YYYY)
  - My Movie (YYYY).imdb  # contains imdb id
  - My Movie (YYYY).mp4
  ...
```

Then run

```sh
kodi-nfo-gen --fanart download --overwrite --verbose --recursive --dir Movies/
```

> Ensure that any `.nfo` files are changed to `movie.nfo`

## TV Shows

```
Shows
- My Show (YYYY)
  - Season 01
    - My Show S01E01.mp4
    - My Show S01E02-E03.mp4
  - My Show (YYYY).imdb
```

Then run

```sh
kodi-nfo-gen --episodes --fanart download --overwrite --verbose --recursive --dir Shows/
```

> For nfo's with multiple episodes they can have multiple blocks of `<episodedetails>...</episodedetails>`.

# `get-iplayer`

> You are legally responsible for any videos produced from these commands and should not redistribute material without correct licenses from the original creators.

Use a nix shell to get the latest package `nix-shell -p get_iplayer`.

To retrieve a low quality 25fps copy with a resolution around 704x396.

`get_iplayer --tv-lower-bitrate --subtitles --tv-quality=396p --url=<url>`

To retrieve a standard definition 25fps copy with a resolution around 960x540.

`get_iplayer --tv-lower-bitrate --subtitles --tv-quality=540p --url=<url>`

To retrieve a high definition 50fps copy with a resolution around 1280x720.

`get_iplayer --subtitles --tv-quality=720p --url=<url>`

See https://github.com/get-iplayer/get_iplayer/wiki/quality for mode information.

# FLAC

Test if a flac file is corrupt.

```sh
flac -t *.flac
```

Fix a corrupt flac file

```sh
flac --verify --compression-level-0 --decode-through-errors --preserve-modtime -o out.flac in.flac
```

# DVD

## MakeMKV

  * Install MakeMKV

> If you need a license key navigate to (https://forum.makemkv.com/forum/viewtopic.php?t=1053)

Find which titles are the main title and extras you want (https://www.dvdcompare.net) can be useful for finding lengths of extras.

Then extract all of them to a folder.

## Handbrake

Ensure that passthrough occurs for audio / subtitles / cropping.

Then pick mkv as the container with h264 as the codec format.
