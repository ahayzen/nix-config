# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

#
# Test the following
#
# Lab
# - joplin
# - rathole
# - backup machines of lab
#
# VPS
# - caddy
# - rathole
#
# Backup
# - backup script

(import ./lib.nix) {
  name = "lab-joplin-test";
  nodes = {
    vps = { self, pkgs, ... }: {
      imports =
        [
          self.nixosModules.headlessSystem
          ../nixos/hosts/vps/default.nix
          ../nixos/users/headless
        ];

      ahayzen = {
        testing = true;

        vps = {
          rathole = true;
          glances = false;
          homepage = false;
          wagtail-ahayzen = false;
          wagtail-yumekasaito = false;
        };
      };

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        "127.0.0.1" = [ "joplin.hayzen.uk" "ahayzen.com" "yumekasaito.com" ];
      };

      # Preseed host key
      services.openssh.hostKeys = [ ];
      environment.etc = {
        # Map the test SSH key for backups
        "ssh/ssh_host_ed25519_key" = {
          mode = "0400";
          source = ./files/test_vps_ssh_id_ed25519;
        };
        "ssh/ssh_host_ed25519_key.pub".source = ./files/test_vps_ssh_id_ed25519.pub;
      };

      # Allow test ssh authentication
      users.users.headless.openssh.authorizedKeys.keyFiles = [
        ./files/test_backup_ssh_id_ed25519.pub
        ./files/test_lab_ssh_id_ed25519.pub
      ];

      # Match VPS specifications
      virtualisation = {
        cores = 2;
        # Increase so we can fit docker images
        diskSize = 2 * 1024;
        memorySize = 2 * 1024;
      };
    };

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
          actual = false;
          audiobookshelf = false;
          bitwarden = false;
          glances = false;
          immich = false;
          jellyfin = false;
          joplin = true;
          rathole = true;
          restic = false;
          sftpgo = false;
        };
      };

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        # TODO: can we fix the IP addresses of the testing hosts?
        "192.168.1.3" = [ "joplin.hayzen.uk" "ahayzen.com" "yumekasaito.com" ];
      };

      # Preseed host hey so we can run automatic backups
      services.openssh = {
        hostKeys = [ ];

        # Seed known hosts
        knownHosts = {
          vps = {
            extraHostNames = [ "ahayzen.com" ];
            publicKeyFile = ./files/test_vps_ssh_id_ed25519.pub;
          };
        };
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

          # Map restore fixtures
          "ahayzen.com/restore/fixtures".source = ./fixtures/vps;

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
          vps = {
            extraHostNames = [ "ahayzen.com" ];
            publicKeyFile = ./files/test_vps_ssh_id_ed25519.pub;
          };
        };
      };

      # Setup IdentityFile
      programs.ssh.extraConfig = builtins.readFile ./files/ssh_config;
    };
  };

  testScript = ''
    import datetime

    start_all()

    labdayofweek = ""
    vpsdayofweek = ""

    #
    # Test that the VPS boots and shows wagtail admin
    #

    with subtest("Ensure docker starts and caddy starts"):
      # Wait for docker runner
      vps.wait_for_unit("docker-compose-runner", timeout=120)

      # Wait for caddy to start
      vps.wait_for_open_port(80, timeout=60)

    #
    # Test that Lab works
    #

    with subtest("Ensure docker starts"):
      lab.wait_for_unit("docker-compose-runner", timeout=240)

    with subtest("Rathole connection"):
      # Check we have a server control channel
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "rathole::server: Control channel established service=joplin"' , timeout=10)

      # Check we have a client control channel
      lab.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "rathole::client: Control channel established"' , timeout=10)

    with subtest("Test joplin"):
      # Wait for joplin to start
      wait_for_joplin_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "App: Public base URL: https://joplin.hayzen.uk"'
      lab.wait_until_succeeds(wait_for_joplin_cmd, timeout=60)

      # Wait for API to be ready
      wait_for_joplin_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "App: Call this for testing"'
      lab.wait_until_succeeds(wait_for_joplin_cmd, timeout=60)

      # Query API
      output = vps.succeed("curl --insecure --location --silent joplin.hayzen.uk/api/ping")
      assert "Joplin" in output, f"'{output}' does not contain 'Joplin'"

      # Test login page
      output = vps.succeed("curl --insecure --location --silent joplin.hayzen.uk/login")
      assert "Joplin" in output, f"'{output}' does not contain 'Joplin'"

    #
    # Test that we can backup lab
    #

    with subtest("Ensure SSH is ready"):
      lab.wait_for_open_port(8022, timeout=30)

    with subtest("Attempt to run lab backup"):
      backup.succeed("mkdir -p /tmp/backup-root-lab")

      # Check that the permissions are correct
      lab.succeed("ls -nd /var/lib/docker-compose-runner/joplin/data/db.sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Trigger a snapshot
      labdayofweek = datetime.datetime.today().strftime('%w')
      lab.succeed("systemctl start joplin-db-snapshot.service")

      # Run the backup
      backup.succeed("/etc/ahayzen.com/backup.sh lab /etc/ssh/test_ssh_id_ed25519 headless@lab /tmp/backup-root-lab")

      # Check volumes are appearing
      backup.succeed("test -d /tmp/backup-root-lab/docker-compose-runner/joplin/data")

      # Check that known files exist and permissions are correct
      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/joplin/data/db-snapshot-" + labdayofweek + ".sqlite")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/joplin/data/db-snapshot-" + labdayofweek + ".sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/joplin/data/db.sqlite")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/joplin/data/db.sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")


    #
    # Test auto backup in lab
    #
    # Do this after other backups so that we have snapshots
    with subtest("Test Auto Backup Machines"):
      # Run backup command
      lab.succeed("systemctl start backup-machines.service")

      #
      # Check lab is correct
      #

      # Check volumes are appearing
      lab.succeed("test -d /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/joplin/data")

      # Check that known files exist and permissions are correct
      lab.succeed("test -e /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/joplin/data/db-snapshot-" + labdayofweek + ".sqlite")
      lab.succeed("ls -nd /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/joplin/data/db-snapshot-" + labdayofweek + ".sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      lab.succeed("test -e /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/joplin/data/db.sqlite")
      lab.succeed("ls -nd /mnt/pool/data/backup/lab/var/lib/docker-compose-runner/joplin/data/db.sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

    with subtest("General metrics (lab)"):
      print(lab.succeed("cat /etc/hosts"))
      print(lab.succeed("ps auxf"))
      print(lab.succeed("free -h"))
      print(lab.succeed("df -h"))
      print(lab.succeed("docker images"))
      print(lab.succeed("docker stats --no-stream"))

    with subtest("General metrics (vps)"):
      print(vps.succeed("cat /etc/hosts"))
      print(vps.succeed("ps auxf"))
      print(vps.succeed("free -h"))
      print(vps.succeed("df -h"))
      print(vps.succeed("docker images"))
      print(vps.succeed("docker stats --no-stream"))
  '';
}
