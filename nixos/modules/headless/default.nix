# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }: {
  imports = [
    ./bindfs.nix
    ./docker.nix
    ./docker-compose.nix
    ./fail2ban.nix
    ./ssh.nix
  ];

  config = {
    ahayzen.headless = true;

    environment.systemPackages = with pkgs; [
      # Install sqlite3 so that backups can take snapshots of databases
      sqlite
      # Install zellij for persistent sessions
      zellij
    ];

    # If we are a laptop ignore the lid being shut
    services.logind.lidSwitch = "ignore";
  };
}
