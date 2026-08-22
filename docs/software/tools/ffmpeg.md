<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# ffmpeg

## Fix incorrect aspect ratio

```console
nix-shell -p ffmpeg
ffmpeg -i input.mkv -map 0 -c copy -aspect 16:9 output.mkv 
```
