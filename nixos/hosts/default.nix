# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ hostname, lib, ... }: {
  imports = [ ]
    # Include the host specific config if there is one
    ++ lib.optional (builtins.pathExists (./. + "/${hostname}")) ./${hostname};
}
