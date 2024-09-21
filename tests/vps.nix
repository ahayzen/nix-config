# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

#
# Test the following
#
# VPS
# - caddy
# - homepage
# - wagtail-ahayzen
# - wagtail-yumeaksaito
#
# Lab
# - backup machines of VPS
#
# Backup
# - backup script
# - restore script

(import ./lib.nix) {
  name = "vps-test";
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
          rathole = false;
          glances = true;
          homepage = true;
          wagtail-ahayzen = true;
          wagtail-yumekasaito = true;
        };
      };

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        "127.0.0.1" = [ "actual.hayzen.uk" "bitwarden.hayzen.uk" "immich.hayzen.uk" "ahayzen.com" "home.hayzen.uk" "hayzen.uk" "yumekasaito.com" ];
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

    lab = { self, pkgs, ... }: {
      imports =
        [
          self.nixosModules.headlessSystem
          ../nixos/hosts/lab/default.nix
          ../nixos/users/headless
        ];

      ahayzen = {
        testing = true;

        lab = {
          actual = false;
          bitwarden = false;
          glances = true;
          immich = false;
          rathole = false;
          restic = false;
        };
      };

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        # TODO: can we fix the IP addresses of the testing hosts?
        "192.168.1.3" = [ "actual.hayzen.uk" "bitwarden.hayzen.uk" "immich.hayzen.uk" "ahayzen.com" "home.hayzen.uk" "hayzen.uk" "yumekasaito.com" ];
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

    wait_for_wagtail_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "\[INFO\] Listening at: http:\/\/0\.0\.0\.0:8080"'

    #
    # Test that the VPS boots and shows wagtail admin
    #

    with subtest("Ensure docker starts and caddy starts"):
      # Wait for docker runner
      vps.wait_for_unit("docker-compose-runner", timeout=120)

      # Wait for caddy to start
      vps.wait_for_open_port(80, timeout=60)

      # Wait for fail2ban jails to appear
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --grep "INFO Jail \'sshd\' started"', timeout=60)
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --grep "INFO Jail \'caddy\' started"', timeout=60)

    with subtest("Ensure wagtail has started"):
      # Wait for at least two wagtails to start
      vps.wait_until_succeeds(wait_for_wagtail_cmd + " | wc -l | awk '{if ($1 > 1) {exit 0} else {exit 1}}'", timeout=60)

      # Test that ahayzen admin page exists
      output = vps.succeed("curl --insecure --location --silent ahayzen.com/admin/login/?next=/admin/")
      assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"

      # Test that wagtail port is not open externally
      vps.fail("curl --silent ahayzen.com:8080")

      # Test that yumekasaito admin page exists
      output = vps.succeed("curl --insecure --location --silent yumekasaito.com/admin/login/?next=/admin/")
      assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"

      # Test that wagtail port is not open externally
      vps.fail("curl --silent yumekasaito.com:8080")

      # Test that static hayzen.uk site works
      output = vps.succeed("curl --insecure --location --silent hayzen.uk")
      assert "Andrew" in output, f"'{output}' does not contain 'Andrew'"
      assert "Yumeka" in output, f"'{output}' does not contain 'Yumeka'"

    with subtest("Ensure that homepage has started"):
      # Wait for homepage to start
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "Listening on port 3000"', timeout=30)

      # Test that we can access the homepage
      output = vps.succeed("curl --insecure --location --silent home.hayzen.uk")
      # Note we cannot test for "Hayzen Home" our title as using curl
      # doesn't load the actual settings but just the default page
      assert "Home" in output, f"'{output}' does not contain 'Home'"

    with subtest("Ensure that glances has started"):
      lab.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "Uvicorn running on http://0.0.0.0:61208"', timeout=30)
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "Uvicorn running on http://0.0.0.0:61208"', timeout=30)

    #
    # Test that we can backup and restore the VPS
    #

    with subtest("Ensure SSH is ready"):
      vps.wait_for_open_port(8022, timeout=30)

    with subtest("Attempt to run a backup"):
      backup.succeed("mkdir -p /tmp/backup-root-vps")

      # Check that the permissions are correct
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Trigger a snapshot
      vpsdayofweek = datetime.datetime.today().strftime('%w')
      vps.succeed("systemctl start periodic-daily.service")

      # Run the backup
      backup.succeed("/etc/ahayzen.com/backup.sh vps /etc/ssh/test_ssh_id_ed25519 headless@vps /tmp/backup-root-vps")

      # Check volumes are appearing
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/caddy/persistent")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/caddy/config")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/media")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/static")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/media")
      backup.succeed("test -d /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/static")

      # Check that known files exist and permissions are correct
      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-" + vpsdayofweek + ".sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-" + vpsdayofweek + ".sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-" + vpsdayofweek + ".sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-" + vpsdayofweek + ".sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

    # TODO: note this does not restore wagtail-yumekasaito
    with subtest("Attempt to run a restore (only wagtail-ahayzen)"):
      # Check the home does not contain restore key
      output = vps.succeed("curl --insecure --location --silent ahayzen.com")
      assert "Restore Unit Test" not in output, f"'{output}' does contain 'Restore Unit Test'"

      # Copy fixtures to a /tmp folder so that we can fix permissions
      # as environment.etc.<name>.user only affects files
      backup.succeed("mkdir -p /tmp/restore-root")
      backup.succeed("cp -R /etc/ahayzen.com/restore/fixtures/* /tmp/restore-root/")
      backup.succeed("chown -R 2000:2000 /tmp/restore-root/")

      # Check files exist and permissions are correct
      backup.succeed("test -d /tmp/restore-root/test-page/docker-compose-runner/wagtail-ahayzen/db")
      backup.succeed("test -e /tmp/restore-root/test-page/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3")
      backup.succeed("ls -nd /tmp/restore-root/test-page/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Run the restore
      backup.succeed("/etc/ahayzen.com/restore.sh vps /etc/ssh/test_ssh_id_ed25519 headless@vps /tmp/restore-root/test-page")

      # Check that the permissions are still correct
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Wait for services to restart and second occurance of Listening at
      vps.wait_for_unit("docker-compose-runner", timeout=90)
      vps.wait_for_open_port(80, timeout=60)
      vps.wait_until_succeeds(wait_for_wagtail_cmd + " | wc -l | awk '{if ($1 > 3) {exit 0} else {exit 1}}'", timeout=60)

      # Check the home does contain restore key
      output = vps.succeed("curl --insecure --location --silent ahayzen.com")
      assert "Restore Unit Test" in output, f"'{output}' does not contain 'Restore Unit Test'"

    #
    # Test that we can backup lab
    #

    with subtest("Ensure SSH is ready"):
      lab.wait_for_open_port(8022, timeout=30)

    #
    # Test auto backup in lab
    #
    # Do this after other backups so that we have snapshots
    with subtest("Test Auto Backup Machines"):
      # Run backup command
      lab.succeed("systemctl start backup-machines.service")

      #
      # Check vps is correct
      #

      # Check volumes are appearing
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/caddy/persistent")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/caddy/config")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/db")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/media")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/static")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/db")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/media")
      lab.succeed("test -d /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/static")

      # Check that known files exist and permissions are correct
      lab.succeed("test -e /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-" + vpsdayofweek + ".sqlite3")
      lab.succeed("ls -nd /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-" + vpsdayofweek + ".sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      lab.succeed("test -e /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3")
      lab.succeed("ls -nd /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      lab.succeed("test -e /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-" + vpsdayofweek + ".sqlite3")
      lab.succeed("ls -nd /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-" + vpsdayofweek + ".sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      lab.succeed("test -e /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3")
      lab.succeed("ls -nd /mnt/data/backup/vps/latest/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

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
