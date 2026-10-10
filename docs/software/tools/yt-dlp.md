<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# `yt-dlp`

> You are legally responsible for any videos produced from these commands and should not redistribute material without correct licenses from the original creators.

Use a nix shell to get the latest package

```bash
nix-shell -p yt-dlp
```

## MP4

```bash
yt-dlp --write-subs --write-auto-subs --sub-format "srt/best" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "%(title)s.%(ext)s" <url>
```

## Playlist

```bash
yt-dlp --write-subs --write-auto-subs --sub-format "srt/best" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --yes-playlist -o "%(title)s.%(ext)s" <url>
```
