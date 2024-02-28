# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ headless, lib, ... }: {
  imports = [
    # Include the common config
    ./modules/all
  ]
  # Include headless config
  ++ lib.optional (headless) ./modules/headless
  # Include desktop config if not headless
  ++ lib.optional (!headless) ./modules/desktop
  ++ [
    # Include the host specific config
    ./hosts
    # Include the user specific config
    ./users
  ];
}
