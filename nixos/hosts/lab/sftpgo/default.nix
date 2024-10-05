# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.sftpgo = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.sftpgo) {
    ahayzen = {
      docker-compose-files = [ ./compose.sftpgo.yml ];

      # Take a snapshot of the database daily
      periodic-daily-commands = [
        ''/run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/sftpgo/sftpgo.db ".backup /var/lib/docker-compose-runner/sftpgo/sftpgo-snapshot-$(date +%w).db"''
      ];
    };

    services.avahi = {
      # Expose WebDav
      extraServiceFiles = {
        webdav = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_webdav._tcp</type>
              <port>8090</port>
              <txt-record>path=/</txt-record>
            </service>
          </service-group>
        '';
      };
    };

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to sshfs
    systemd.services."docker-compose-runner-pre-init-sftpgo" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/app/sftpgo/backups
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/user

          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/camera
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/documents
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/music
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/movies
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/recordings
          ${pkgs.coreutils}/bin/mkdir -p /mnt/data/shows

          ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/sftpgo
        '';
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # Ensure WebDav port is open
    networking.firewall.allowedTCPPorts = [
      8090
    ];
  };
}
