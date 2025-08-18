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

Other data

```
/app/
/backup/
/documents/
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

Using libisoburn specific commands

```bash
nix-shell -p dvdisaster libisoburn

# Create the ISO
xorrisofs -V "ARCHIVE_2000" -J -joliet-long --modification-date=$(date +%Y%m%d%H%M%S%2N) -R -o output.iso /input/folder

# Embed parity info into the ISO
dvdisaster -i output.iso -mRS03 -x$(nproc) -c

# Burn the ISO to disk (formatting to enable BD Defect Management)
xorrecord blank=format_overwrite dev=/dev/sr0 speed=4b output.iso -v

# Verify the disk
dvdisaster -d /dev/sr0 -s
```
