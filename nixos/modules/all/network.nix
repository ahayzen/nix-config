# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ hostname, ... }: {
  # Define the hostname of the device
  networking.hostName = "${hostname}";
}
