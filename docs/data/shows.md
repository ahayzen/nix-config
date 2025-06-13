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

## Meta data

Firstly find the TV show on IMDB and then create a file named .imdb with the id as the contents.

Run the following command over the TV show folder to generate the nfo.

```console
pip install kodi_nfo_generator

kodi-nfo-gen --episodes --fanart download --overwrite --verbose --recursive --dir Shows/
```

> For nfo's with multiple episodes they can have multiple blocks of `<episodedetails>...</episodedetails>`.

## `get-iplayer`

> You are legally responsible for any videos produced from these commands and should not redistribute material without correct licenses from the original creators.

Use a nix shell to get the latest package

```console
nix-shell -p get_iplayer
```

Use the following for good defaults.

```console
// For movies
get_iplayer --file-prefix="<name> (<releaseyear>)" --tv-quality="1080p,720p,540p" --subtitles --whitespace --url=<url>

// For TV shows
get_iplayer --file-prefix="<nameshort> S<00seriesnum>E<00episodenum>" --subdir --subdir-format="Season <00seriesnum>" --tv-quality="1080p,720p,540p" --subtitles --whitespace --pid=<pid> --pid-recursive
```

To retrieve a low quality 25fps copy with a resolution around 704x396.

```console
get_iplayer --tv-lower-bitrate --subtitles --tv-quality=396p --url=<url>
```

To retrieve a standard definition 25fps copy with a resolution around 960x540.

```console
get_iplayer --tv-lower-bitrate --subtitles --tv-quality=540p --url=<url>
```

To retrieve a high definition 50fps copy with a resolution around 1280x720.

```console
get_iplayer --subtitles --tv-quality=720p --url=<url>
```

> See [https://github.com/get-iplayer/get_iplayer/wiki/quality] for mode information.

You can also download a whole series with the following command.

The pid should be made from the series page and use that hash from `seriesId=` that is not the programme.

```console
get_iplayer --tv-lower-bitrate --subtitles --tv-quality=540p --pid=<pid> --pid-recursive
```
