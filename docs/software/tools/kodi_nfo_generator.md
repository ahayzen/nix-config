<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# `kodi-nfo-gen`

> Changes to IMDB have caused `kodi-nfo-gen` not to work

## Install

```console
$ pip install kodi_nfo_generator
```

## Movies

Run the following command over the movie folder to generate the nfo.

```console
$ kodi-nfo-gen --fanart download --overwrite --verbose --recursive --dir movies/
```

> Ensure that any `.nfo` files are changed to `movie.nfo`

## Shows

Run the following command over the TV show folder to generate the nfo.

```console
kodi-nfo-gen --episodes --fanart download --overwrite --verbose --recursive --dir Shows/
```

> For nfo's with multiple episodes they can have multiple blocks of `<episodedetails>...</episodedetails>`.