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
