<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Backup to Blu-ray

Using the [Archive](../../data/archive.md) data structure each year can be copied individually for non-replaceable data.

## Determine folders for each disc

First find the size of the folders for the year.

```bash
export YEAR=2026
sudo du --human-readable --max-depth=2 --si /mnt/pool/data/camera/ /mnt/pool/data/photostream/ /mnt/pool/data/recordings/ /mnt/pool/data/user/*/Camera/ | sort -hr | grep $YEAR
```

Then use a first-fit bin packing algorithm to sort the folders into discs.

> Max size for BD-R with parity is 20G, BD-XL 80G, [Blu-ray](../../hardware/bluray.md) for more specs

## Copy each folder

> This can be used to either for using offline HDD or for preparing files for Blu-ray.

Use the following commands to copy the data and verify the checksum.

```bash
export IDENTITY_FILE="~/.ssh/id_ed25519"
export SSH_PORT=22
export SRC_DIR=/mnt/pool/data
export SRC="user@host:$SRC_DIR"
export DEST=./Archive

# Create a checksum on the source
find $SRC_DIR -type f | sort | xargs -I {} sh -c "sha256sum '{}' | head -c 64" | sha256sum

# Copy the files from the source
rsync --archive --checksum --human-readable --ignore-times --mkpath --partial --progress --rsh="ssh -i $IDENTITY_FILE -p $SSH_PORT" --rsync-path="sudo rsync" $SRC $DEST

# Create a checksum on the destination
find $DEST -type f | sort | xargs -I {} sh -c "sha256sum '{}' | head -c 64" | sha256sum
```

## Build ISO

Use [Libburnia](./../../software/tools/libburnia.md) and [dvdisaster](./../../software/tools/dvdisaster.md) to create an ISO file with party data.

```bash
nix-shell -p dvdisaster libisoburn

# Create the ISO
export SRC=./Archive
xorrisofs -V "ARCHIVE_2000" -J -joliet-long --modification-date=$(date +%Y%m%d%H%M%S%2N) -R -o output.iso $SRC

# Embed parity info into the ISO
dvdisaster -i output.iso -mRS03 -x$(nproc) -c
```

> If a file is larger than 4 GiB then use `-iso-level 3`

## Burn ISO

Then burn this ISO to disk using BD Defect Management and verify the contents.

```bash
nix-shell -p dvdisaster libisoburn

# Burn the ISO to disk (formatting to enable BD Defect Management)
xorrecord blank=format_overwrite dev=/dev/sr0 speed=4b output.iso -nopad -v

# Verify the disk
dvdisaster -d /dev/sr0 -s
```

## Create a QR Code

Information can be output into a QR code.

```bash
nix-shell -p qrencode

echo "Label: ARCHIVE_2000" > info.md
echo "Date: $(date)" >> info.md
echo "Hash: $(sha256sum output.iso)" >> info.md
echo "Parity: dvdisaster=RS03" >> info.md
echo "Contents:" >> info.md
find ./Archive/ -type d -printf '%P\n' >> info.md
# Trim any extra folder information here

qrencode -s 6 -l H -o qr.png < info.md
```

## Create a PDF

Now create a PDF file with a 12cm x 12cm area containing the QR code and `ARCHIVE_2000`.

This should then fit inside the jewel case.

Create the following `cover.tex` file and enter the label and QR image.

```tex
\documentclass{article}
\usepackage{graphicx}
\usepackage{geometry}
\geometry{a4paper, margin=2cm}

\begin{document}

\fbox{%
  \begin{minipage}[c][12cm][c]{12cm}
    \centering
    \Large{Archive YYYY-YYYY}

    \includegraphics[width=0.75\textwidth]{qr.png}
  \end{minipage}
}

\vfill

\fbox{%
  \begin{minipage}[c][12cm][c]{12cm}
    \centering
    \Large{Archive YYYY-YYYY}

    \includegraphics[width=0.75\textwidth]{qr.png}
  \end{minipage}
}

\end{document}
```

Now convert this to a pdf.

```console
nix-shell -p texlive.combined.scheme-small

pdflatex cover.tex
```
