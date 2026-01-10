<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Verbatim 43888

This is a BDXL Bluray drive.

## Cable

Do not use the supplied USB A to C conversion cable, instead use a USB C to C, otherwise the drive does not receive enough power.

## MakeMKV

With Linux versions of MakeMKV newer than 1.17.7 it cannot dump the drive firmware and appears to hang on startup.

To resolve this

  * Open an old version of MakeMKV (eg 1.17.6 as an [appimage](https://github.com/uncle-ben-devel/makemkv-appimage/releases/download/1.17.6/MakeMKV-x86_64.AppImage))
  * Attach the drive with a disc
  * Notice a `dump_FW_*.tgz` appears in `~/.MakeMKV/`
  * Make a copy of this file
  * Launch newer versions of MakeMKV and this should work

## Permissions

Ensure that your user has permission to write to `/dev/sr0` (eg is in the `cdrom` group)
