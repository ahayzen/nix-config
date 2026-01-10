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

### Collections

If there are multiple movies that are part of a collection this information can be added to the NFO file.

```xml
<set>
  <name>My Movie Collection</name>
  <overview>My Movie Overview.</overview>
</set>
<collectionnumber>NNNN</collectionnumber>
```

> The collection number can be found on TheMovieDB

For this to work in Jellyfin ensure the following

  * Libraries -> Movies -> Automatically add to collection is enabled
  * Metadata manager -> Collections -> Collection is not lock (rescan all libraries after unlocking)

> Do not rescan just the collections library, rescan all libraries

## DVD

> You are legally responsible for any videos produced from these commands and should not redistribute material without correct licenses from the original creators.

Attempt to use MakeMKV first and then fallback to other options.

### MakeMKV

Use [MakeMKV](https://flathub.org/apps/com/makemkv/MakeMKV) to extract the DVD into MKV files.

> If you need a license key navigate to (https://forum.makemkv.com/forum/viewtopic.php?t=1053)

Find which titles are the main title and extras you want (https://www.dvdcompare.net) can be useful for finding lengths of extras.

Then extract all of them to a folder.

#### Manual Mode

For certain media the playlist can confuse MakeMKV, if this happens.

  * Open the DVD in VLC and note the track number of the title
  * Enable Expert mode in MakeMKV settings
  * Tick `Open DVD Manually` before scanning the disc
  * Type the number of the track to rip

### Handbrake

Ensure that passthrough occurs for audio / subtitles / cropping.

Then pick mkv as the container with h264 as the codec format.

  * [MKV h264 576p DVD preset](./handbrake_dvd_h264_mkv_passthrough_576p25.json)

> Use the preview to check for any interlace set the following under filters
> Detelecine: Default
> Interlace Detection: Decomb
> Deinterlace: Default

### MKVToolNix

Use [MKVToolNix](https://flathub.org/apps/org.bunkus.mkvtoolnix-gui) to adjust MKV metadata.

Eg if the audio tracks need reordering and changing of default.
