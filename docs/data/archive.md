<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Archive

For cold-storage or archiving there are a few options

  * Using an offline HDD
  * Using Blu-ray disks

## Sources

Non-recoverable data (eg personal data not music / movies) are found in the following locations.

Year based data

```
/camera/<year>/
/photostream/<user>/<year>/
/recordings/<year>/
/user/<user>/Camera/<year>/
```

> The following command can be used to discover folder sizes `sudo du --human-readable --max-depth=2 /camera /photostream /recordings /user/<user>/Camera | sort -k2`

Other data

```
/app/
/backup/
/documents/
/files/
/user/<user>/
````

## Copy files

> This can be used to either for using offline HDD or for preparing files for Blu-ray.

Use the following commands to copy the data and verify the checksum.

```bash
export IDENTITY_FILE="~/.ssh/id_ed25519"
export SSH_PORT=22
export SRC=user@host:/src
export DEST=/dest

# Create a checksum on the source
find $SRC -type f | sort | xargs -I {} sh -c "sha256sum '{}' | head -c 64" | sha256sum

# Copy the files from the source
rsync --archive --checksum --human-readable --ignore-times --mkpath --partial --progress --rsh="ssh -i $IDENTITY_FILE -p $SSH_PORT" --rsync-path="sudo rsync" $SRC $DEST

# Create a checksum on the destination
find $DEST -type f | sort | xargs -I {} sh -c "sha256sum '{}' | head -c 64" | sha256sum
```

## Blu-ray

We need to do the following steps

  * Create an ISO from files
  * Embedded parity info into the ISO
  * Burn the ISO to a disk

> Aim for around 20-30% of parity data

> Ensure that your user has permission to write to `/dev/sr0` (eg is in the `cdrom` group)

Using libisoburn specific commands

```bash
nix-shell -p dvdisaster libisoburn

# Create the ISO
xorrisofs -V "ARCHIVE_2000" -J -joliet-long --modification-date=$(date +%Y%m%d%H%M%S%2N) -R -o output.iso /input/folder

# Embed parity info into the ISO
dvdisaster -i output.iso -mRS03 -x$(nproc) -c

# Burn the ISO to disk (formatting to enable BD Defect Management)
xorrecord blank=format_overwrite dev=/dev/sr0 speed=4b output.iso -nopad -v

# Alternatively the following command can format with BD Defect Management disabled
# xorrecord blank=as_needed dev=/dev/sr0 speed=4b output.iso -v

# Verify the disk
dvdisaster -d /dev/sr0 -s
```

> When using BD Defect Management xorrecord padding needs to be disabled for the ISO to fit

> When using BD Defect Management this writes at a slower (half) speed

> If a file is larger than 4 GiB then use `-iso-level 3`

## QR Code

Information can be output into a QR code.

```console
nix-shell -p qrencode

echo "Label: ARCHIVE_2000" > info.md
echo "Date: $(date)" >> info.md
echo "Hash: $(sha256sum output.iso)" >> info.md
echo "Parity: dvdisaster=RS03" >> info.md
echo "Contents:" >> info.md
find ./input/folder/ -type d -printf '%P\n' >> info.md
# Trim any extra folder information here

qrencode -s 6 -l H -o qr.png < info.md
```

Now create a PDF file with a 12cm x 12cm area containing the QR code and `ARCHIVE_2000`.

This should then fit inside the jewel case.

## PDF CD Cover

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
