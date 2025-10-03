# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  options.ahayzen.lab.bitwarden = lib.mkOption {
    default = !config.ahayzen.testing;
    type = lib.types.bool;
  };

  config = lib.mkIf (config.ahayzen.lab.bitwarden) {
    ahayzen.docker-compose-files = [ ./compose.bitwarden.yml ];

    age.secrets = lib.mkIf (!config.ahayzen.testing) {
      bitwarden_env = {
        file = ../../../../secrets/bitwarden_env.age;
        # Set correct owner otherwise docker cannot read the file
        mode = "0600";
        owner = "unpriv";
        group = "unpriv";
      };
    };

    environment.etc = {
      "bitwarden/settings.env".
      source =
        if config.ahayzen.testing
        then ./bitwarden.vm.env
        else config.age.secrets.bitwarden_env.path;
    };

    # Restart if static files change
    #
    # Note agenix files are not possible and will need the version bumping
    # which causes the hash of the docker-compose file to change.
    systemd.services."docker-compose-runner".restartTriggers = [
      # Agenix path with a version that can be bumped
      "/etc/bitwarden/settings.env-1"
    ];

    # As the folders are mapped we need to create with the right permissions
    #
    # Note that this needs to be added as requires and after to mergerfs
    systemd.services."docker-compose-runner-pre-init-bitwarden" = {
      wantedBy = [ "docker-compose-runner.service" ];
      before = [ "docker-compose-runner.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.coreutils}/bin/mkdir -p /var/cache/docker-compose-runner/bitwarden/config";
        User = "unpriv";
        Group = "unpriv";
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # Take snapshot of the database daily
    systemd.services."bitwarden-db-snapshot" = {
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.coreutils}/bin/mkdir -p /var/lib/docker-compose-runner/bitwarden/config
        /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/cache/docker-compose-runner/bitwarden/config/vault.db ".backup /var/lib/docker-compose-runner/bitwarden/config/vault-snapshot-$(date +%w).db"
      '';
    };

    systemd.timers."bitwarden-db-snapshot" = {
      enable = !config.ahayzen.testing;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "22:15";
        Unit = "bitwarden-db-snapshot.service";
        Persistent = true;
      };
    };
  };
}
