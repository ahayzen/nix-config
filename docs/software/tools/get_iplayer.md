<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# `get-iplayer`

> You are legally responsible for any videos produced from these commands and should not redistribute material without correct licenses from the original creators.

Use a nix shell to get the latest package

```console
nix-shell -p get_iplayer
```

Use the following for good defaults.

## Movies

```console
get_iplayer --file-prefix="<name> (<releaseyear>)" --tv-quality="1080p,720p,540p" --subtitles --whitespace --url=<url>
```

## TV Shows

```console
get_iplayer --file-prefix="<nameshort> S<00seriesnum>E<00episodenum>" --subdir --subdir-format="Season <00seriesnum>" --tv-quality="1080p,720p,540p" --subtitles --whitespace --pid=<pid> --pid-recursive
```

## Quality Settings

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

## Recursive

You can also download a whole series with the following command.

The pid should be made from the series page and use that hash from `seriesId=` that is not the programme.

```console
get_iplayer --tv-lower-bitrate --subtitles --tv-quality=540p --pid=<pid> --pid-recursive
```
