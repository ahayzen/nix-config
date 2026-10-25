# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

#
# Test the following
#
# Lab
# - sftpgo
# - backup machines of lab
#
# Backup
# - backup script

(import ./lib.nix) {
  name = "lab-sftpgo-test";
  nodes = {
    lab = { self, lib, pkgs, ... }: {
      imports =
        [
          self.nixosModules.headlessSystem
          ../nixos/hosts/lab-jonsbo-n3/default.nix
          ../nixos/users/headless
        ];

      ahayzen = {
        hostName = lib.mkForce "lab";
        testing = true;

        lab = {
          sftpgo = true;
        };
      };

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        "127.0.0.1" = [ "sftpgo.hayzen.uk" "webdav.hayzen.uk" ];
      };

      # Preseed host hey so we can run automatic backups
      services.openssh = {
        hostKeys = [ ];
      };
      environment.etc = {
        # Map the test SSH key for backups
        "ssh/ssh_host_ed25519_key" = {
          mode = "0400";
          source = ./files/test_lab_ssh_id_ed25519;
        };
        "ssh/ssh_host_ed25519_key.pub".source = ./files/test_lab_ssh_id_ed25519.pub;
      };

      # Allow test ssh authentication
      users.users.headless.openssh.authorizedKeys.keyFiles = [
        ./files/test_backup_ssh_id_ed25519.pub
      ];

      virtualisation = {
        cores = 2;
        # Increase so we can fit docker images
        diskSize = 4 * 1024;
        memorySize = 2 * 1024;
      };
    };

    backup = { self, pkgs, ... }: {
      environment = {
        etc = {
          # Map backup and restore scripts
          "ahayzen.com/backup.sh".source = ../scripts/backup.sh;
          "ahayzen.com/restore.sh".source = ../scripts/restore.sh;

          # Map the test SSH key for backups
          "ssh/test_ssh_id_ed25519" = {
            mode = "0400";
            source = ./files/test_backup_ssh_id_ed25519;
          };
          "ssh/test_ssh_id_ed25519.pub".source = ./files/test_backup_ssh_id_ed25519.pub;
        };

        # Extra packages for the test
        systemPackages = with pkgs; [
          python3
          rsync
        ];
      };

      services.openssh = {
        enable = true;

        # Seed known hosts
        knownHosts = {
          lab.publicKeyFile = ./files/test_lab_ssh_id_ed25519.pub;
        };
      };

      # Setup IdentityFile
      programs.ssh.extraConfig = builtins.readFile ./files/ssh_config;
    };
  };

  testScript = ''
    import datetime
    import zoneinfo

    start_all()

    labdayofweek = ""

    #
    # Test that Lab works
    #

    with subtest("Ensure docker starts"):
      lab.wait_for_unit("docker-compose-runner", timeout=120)
      lab.wait_for_unit("docker-compose-runner-pre-init-sftpgo", timeout=10)

      # Wait for caddy to start
      lab.wait_for_open_port(80, timeout=60)

    with subtest("Test sftpgo"):
      # Wait for sftpgo to start
      wait_for_sftpgo_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "starting SFTPGo"'
      lab.wait_until_succeeds(wait_for_sftpgo_cmd, timeout=60)
      wait_for_sftpgo_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "server listener registered, address"'
      lab.wait_until_succeeds(wait_for_sftpgo_cmd, timeout=60)

      # Test login page direct
      output = lab.succeed("curl --insecure --location --silent sftpgo.hayzen.uk/web/admin/setup")
      assert "WebAdmin" in output, f"'{output}' does not contain 'WebAdmin'"

    with subtest("Test WebDav"):
      # Direct
      output = lab.succeed("curl --insecure --location --verbose webdav.hayzen.uk")
      assert "Authentication error: no credential provided" in output, f"'{output}' does not contain 'Authentication error: no credential provided'"

    #
    # Test that we can backup lab
    #

    with subtest("Ensure SSH is ready"):
      lab.wait_for_open_port(8022, timeout=30)

    with subtest("Attempt to run lab backup"):
      backup.succeed("mkdir -p /tmp/backup-root-lab")

      # Check that the permissions are correct
      lab.succeed("ls -nd /var/cache/docker-compose-runner/sftpgo/sftpgo.db | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Trigger a snapshot
      labdayofweek = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/London")).strftime('%w')
      lab.succeed("systemctl start sftpgo-db-snapshot.service")

      # Run the backup
      backup.succeed("/etc/ahayzen.com/backup.sh lab /etc/ssh/test_ssh_id_ed25519 headless@lab /tmp/backup-root-lab")

      # Check volumes are appearing
      backup.succeed("test -d /tmp/backup-root-lab/docker-compose-runner/sftpgo")

      # Check that known files exist and permissions are correct
      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/sftpgo/sftpgo-snapshot-" + labdayofweek + ".db")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/sftpgo/sftpgo-snapshot-" + labdayofweek + ".db | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")


    #
    # Test auto backup in lab
    #
    # Do this after other backups so that we have snapshots
    with subtest("Test Auto Backup Machines"):
      # Run backup command
      lab.succeed("systemctl start backup-machine-lab.service")

      #
      # Check lab is correct
      #

      # Check volumes are appearing
      lab.succeed("test -d /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/sftpgo/")

      # Check that known files exist and permissions are correct
      lab.succeed("test -e /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/sftpgo/sftpgo-snapshot-" + labdayofweek + ".db")
      lab.succeed("ls -nd /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/sftpgo/sftpgo-snapshot-" + labdayofweek + ".db | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

    with subtest("General metrics (lab)"):
      print(lab.succeed("cat /etc/hosts"))
      print(lab.succeed("ps auxf"))
      print(lab.succeed("free -h"))
      print(lab.succeed("df -h"))
      print(lab.succeed("docker images --all"))
      print(lab.succeed("docker stats --no-stream"))
  '';
}
