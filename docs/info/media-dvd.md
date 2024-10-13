<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

> These are legacy docs that need updating

> Note that you are legally resposible for any videos produced from these commands and should not redistribute material without correct licenses from the original creators.

# DVD

Install MakeMKV and mkvtoolnix (for mkvextract)

```bash
flatpak install flathub com.makemkv.MakeMKV
sudo apt install -y mkvtoolnix
```

Use MakeMKV to extract the titles of the DVD (note you can set the default language for subtitles in the settings). Then set a variable to be filename of the output mkv.

```bash
export FILE_NO_SUFFIX="output-file"
```

Extract the subttitles into vobsubs format, using the default subtitle track number from the first command.

```bash
ffmpeg -i "$FILE_NO_SUFFIX.mkv"
mkvextract tracks "$FILE_NO_SUFFIX.mkv" 2:"$FILE_NO_SUFFIX.idx"
```

Convert the vobsub to srt subtitles.

```bash
vobsub2srt.with-basic-blacklist "$FILE_NO_SUFFIX"
```

Combine the subtitles and convert the mkv to the correct mp4 format (note that we force libx264 and profile main with aac audio so that players such as Synology can understand the format).

```bash
ffmpeg -i "$FILE_NO_SUFFIX.mkv" -i "$FILE_NO_SUFFIX.srt" -map 0:v -r 25 -s 720x576 -c:v libx264 -profile:v main -map 0:a -c:a aac -b:a 320k -ac 2 -map 1:s:0 -c:s mov_text -metadata:s:s:0 language=English -threads $(nproc) "$FILE_NO_SUFFIX.mp4"
```

# iPlayer

To retrieve a low quality 25fps copy with a resolution around 704x396.

`get_iplayer --fps25 --subtitles --tvmode=tvgood --url=<url>`

To retrieve a standard definition 25fps copy with a resolution around 960x540.

`get_iplayer --fps25 --subtitles --tvmode=tvbetter --url=<url>`

To retrieve a high definition 50fps copy with a resolution around 1280x720.

`get_iplayer --subtitles --tvmode=tvbest --url=<url>`

See https://github.com/get-iplayer/get_iplayer/wiki/modes for mode information.

# Video Fixes

## Embed Subtitles

`ffmpeg -i in.mp4 -i in.srt -c copy -c:s mov_text -metadata:s:s:0 language=English out.mp4`

## Volume Fix

`ffmpeg -i input.mp4 -af "volumedetect" -vn -sn -dn -f null /dev/null`

Then adjust the volume so that it has a max volume closer to 0 dB.

`ffmpeg -i input.mp4 -af "volume=5dB" -c:v copy -c:a aac -b:a 192k output.mp4`

# Legacy

## Extract Video and Subtitles from DVD using mencoder

First identify the DVD to find the track number (also check that the subtitle track for English is sid 1).

`mplayer dvd:// -identify`

Then play the track to find out the video dimensions

`mplayer dvd://1 -vf cropdetect`

Then extract the video to AVI with vobsubs, note that --force-avi-aspect needs to match the ratio - see the table below for possible examples.

| Resolution | Aspect |
| ---------- | ------ |
| 720x416    | 2.35   |
| 720x560    | 1.77777|

`mencoder dvd://1 -ovc x264 -vf crop=720:560:0:8,scale=-1:-10,harddup -force-avi-aspect 1.77777 -alang en -oac mp3lame -lameopts br=192 -af volume=10 -channels 2 -srate 48000 -channels 2 -vobsubout subs -vobsuboutindex 0 -sid 1 -o out.avi`

To convert the subtitles from vobsub to srt run the following command.

`vobsub2srt out`

Note if you are using the snap you can use `vobsub2srt.with-basic-blacklist out` to help the OCR.

Then convert the video from AVI to mp4, note the resolution needs to match.

`ffmpeg -i out.avi -i out.srt -r 25 -s 720x560 -c:v libx264 -crf 17 -profile:v main -c:a aac -b:a 192k -ac 2 -c:s mov_text -metadata:s:s:0 language=English -threads $(nproc) out.mp4`

Note that we need to use ffmpeg to convert the generated x264 file again as mencoder creates an encoding that players such as Synology cannot understand, where ffmpeg creates a correct format.