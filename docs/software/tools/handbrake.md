<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Handbrake

> Only use handbrake when required, it is best to keep the original MakeMKV file rather than compressing

Ensure that passthrough occurs for audio / subtitles / cropping.

Then pick mkv as the container with h264 as the codec format.

  * [MKV h264 576p DVD preset](./handbrake_dvd_h264_mkv_passthrough_576p25.json)

> Use the preview to check for any interlace set the following under filters
> Detelecine: Default
> Interlace Detection: Decomb
> Deinterlace: Default