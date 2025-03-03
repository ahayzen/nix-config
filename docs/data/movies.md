<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Movies

How to add and convert movies into the storage.

## Folder structure

There are three file types to consider

* Movie in MKV
* Meta data in NFO
* Cover image in JPG
* Extras in MKV

For a normal movie this means the following

```
/movies
  /My Movies (YYYY)
    /My Movie (YYYY).imdb
    /My Movie (YYYY).mkv
    /folder.jpg
    /movie.nfo
    /extras
      /Trailer.mkv
```

## Meta data

Firstly find the movie on IMDB and then create a file named .imdb with the id as the contents.

Run the following command over the movie folder to generate the nfo.

```console
pip install kodi_nfo_generator

kodi-nfo-gen --fanart download --overwrite --verbose --recursive --dir movies/
```

> Ensure that any `.nfo` files are changed to `movie.nfo`
