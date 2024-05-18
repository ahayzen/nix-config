# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  imports = [
    ./docker.nix
    ./docker-compose.nix
    ./ssh.nix
  ];

  config = {
    ahayzen.headless = true;

    # Install sqlite3 so that backups can take snapshots of databases
    environment.systemPackages = with pkgs; [
      sqlite
    ];
  };
}
