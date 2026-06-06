<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# NFO

NFO are used to define metadata to jellyfin offline.

These files can be generated using [`kode-nfo-gen`](../software/tools/kodi_nfo_generator.md).

## Movies

Template for a `movie.nfo`.

```xml
<?xml version="1.0" ?>
<movie>
  <title>TITLE</title>
  <originaltitle>TITLE</originaltitle>
  <uniqueid type="imdb" default="true">https:www.imdb.comtt0000</uniqueid>
  <plot>DESCRIPTION</plot>
  <outline>DESCRIPTION</outline>
  <mpaa>GB-AA</mpaa>
  <director>DIRECTOR</director>
  <premiered>1970-01-01</premiered>
  <genre>GENRE</genre>
  <actor>
    <name>ACTOR</name>
  </actor>
  <trailer>https://www.imdb.com/video/imdb/vi0000</trailer>
  <ratings>
    <rating name="imdb" max="10">
      <value>10.0</value>
    </rating>
  </ratings>
  <thumb aspect="poster">folder.jpg</thumb>
  <set>
    <name>COLLECTION</name>
    <overview>DESCRIPTION</overview>
  </set>
  <collectionnumber>0000</collectionnumber>
</movie>
```

## TV Shows

Template for `tvshow.nfo`.

```xml
<?xml version="1.0" ?>
<tvshow>
  <title>TITLE</title>
  <originaltitle>TITLE</originaltitle>
  <uniqueid type="imdb" default="true">https:www.imdb.comtt0000</uniqueid>
  <plot>DESCRIPTION</plot>
  <outline>DESCRIPTION</outline>
  <mpaa>GB-AA</mpaa>
  <director>DIRECTOR</director>
  <premiered>1970-01-01</premiered>
  <genre>GENRE</genre>
  <actor>
    <name>ACTOR</name>
  </actor>
  <trailer>https://www.imdb.com/video/imdb/vi0000</trailer>
  <ratings>
    <rating name="imdb" max="10">
      <value>10.0</value>
    </rating>
  </ratings>
  <thumb aspect="poster">folder.jpg</thumb>
</tvshow>
```

Template for `Show S01E01.nfo`.

```xml
<?xml version="1.0" ?>
<episodedetails>
  <season>1</season>
  <episode>1</episode>
  <title>TITLE</title>
  <plot>DESCRIPTION</plot>
  <aired/>
  <uniqueid type="imdb" default="true">tt0000</uniqueid>
  <ratings>
    <ratings name="imdb" max="10" default="true">
      <value>10.0</value>
    </ratings>
  </ratings>
</episodedetails>
```

> For nfo's with multiple episodes they can have multiple blocks of `<episodedetails>...</episodedetails>`.

## Age Rating

```xml
<mpaa>GB-12</mpaa>
```

https://github.com/jellyfin/jellyfin/blob/master/Emby.Server.Implementations/Localization/Ratings/gb.json

## Collections

If there are multiple movies that are part of a collection this information can be added to the NFO file.

```xml
<set>
  <name>My Movie Collection</name>
  <overview>My Movie Overview.</overview>
</set>
<collectionnumber>0000</collectionnumber>
```

> The collection number can be found on TheMovieDB

> In Jellyfin ensure that Libraries -> Movies -> Automatically add to collection is enabled

> Do not rescan just the collections library, rescan all libraries

## Specials

Specials that are in `Season 00` can be ordered using the following tags in NFO files.

  - `<airsbefore_season>SEASON</airsbefore_season>`
  - `<airsafter_season>SEASON</airsafter_season>`
  - `<airsbefore_episode>SEASON</airsbefore_episode>`

https://jellyfin.org/docs/general/server/media/shows/#show-specials
