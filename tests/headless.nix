# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

(import ./lib.nix) {
  name = "vps test";
  nodes = {
    vps = { self, pkgs, ... }: {
      imports =
        [
          self.nixosModules.headlessSystem
          ../nixos/hosts/vps/default.nix
          ../nixos/users/headless
        ];

      ahayzen.testing = true;

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        "127.0.0.1" = [ "actual.ahayzen.com" "bitwarden.ahayzen.com" "ahayzen.com" "yumekasaito.com" ];
      };

      # Allow test ssh authentication
      users.users.headless.openssh.authorizedKeys.keyFiles = [
        ./files/test_ssh_id_ed25519.pub
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

      ahayzen.testing = true;

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      networking.hosts = {
        "vps" = [ "actual.ahayzen.com" "bitwarden.ahayzen.com" "ahayzen.com" "yumekasaito.com" ];
      };

      # Allow test ssh authentication
      users.users.headless.openssh.authorizedKeys.keyFiles = [
        ./files/test_ssh_id_ed25519.pub
      ];

      virtualisation = {
        cores = 2;
        # Increase so we can fit docker images
        diskSize = 4 * 1024;
        memorySize = 2 * 1024;
      };
    };

    # TODO: backup on lab ? or test independently ?
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
            source = ./files/test_ssh_id_ed25519;
          };
          "ssh/test_ssh_id_ed25519.pub".source = ./files/test_ssh_id_ed25519.pub;
        };

        # Extra packages for the test
        systemPackages = with pkgs; [
          python3
          rsync
        ];
      };

      services.openssh.enable = true;

      # Setup IdentityFile
      programs.ssh.extraConfig = builtins.readFile ./files/ssh_config;
    };
  };

  testScript = ''
    import datetime

    start_all()

    wait_for_wagtail_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "\[INFO\] Listening at: http:\/\/0\.0\.0\.0:8080"'

    #
    # Test that the VPS boots and shows wagtail admin
    #

    with subtest("Ensure docker starts and caddy starts"):
      # Wait for docker runner
      vps.wait_for_unit("docker-compose-runner", timeout=120)

      # Wait for caddy to start
      vps.wait_for_open_port(80, timeout=60)

    with subtest("Ensure wagtail has started"):
      # Wait for at least two wagtails to start
      vps.wait_until_succeeds(wait_for_wagtail_cmd + " | wc -l | awk '{if ($1 > 1) {exit 0} else {exit 1}}'", timeout=60)

      # Test that ahayzen admin page exists
      output = vps.succeed("curl --silent ahayzen.com:80/admin/login/?next=/admin/")
      assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"

      # Test that wagtail port is not open externally
      vps.fail("curl --silent ahayzen.com:8080")

      # Test that yumekasaito admin page exists
      output = vps.succeed("curl --silent yumekasaito.com:80/admin/login/?next=/admin/")
      assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"

      # Test that wagtail port is not open externally
      vps.fail("curl --silent yumekasaito.com:8080")

    #
    # Test that we can backup and restore the VPS
    #

    with subtest("Access hostkey"):
      vps.wait_for_open_port(8022, timeout=30)
      # Ensure we allow the host key
      backup.succeed("ssh -vvv -p 8022 -o StrictHostKeyChecking=accept-new headless@vps exit")

    with subtest("Attempt to run a backup"):
      backup.succeed("mkdir -p /tmp/backup-root-vps")

      # Check that the permissions are correct
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Trigger a snapshot
      dayofweek = datetime.datetime.today().strftime('%w')
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
      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-" + dayofweek + ".sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db-snapshot-" + dayofweek + ".sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-" + dayofweek + ".sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot-" + dayofweek + ".sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3")
      backup.succeed("ls -nd /tmp/backup-root-vps/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

    # TODO: note this does not restore wagtail-yumekasaito
    with subtest("Attempt to run a restore (only wagtail-ahayzen)"):
      # Check the home does not contain restore key
      output = vps.succeed("curl --silent ahayzen.com:80/")
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
      output = vps.succeed("curl --silent ahayzen.com:80/")
      assert "Restore Unit Test" in output, f"'{output}' does not contain 'Restore Unit Test'"

    #
    # Test that Lab works
    #

    with subtest("Ensure docker starts"):
      lab.wait_for_unit("docker-compose-runner", timeout=120)

    with subtest("Rathole connection"):
      # Check we have a server control channel
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "rathole::server: Control channel established service=actual"' , timeout=10)
      vps.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "rathole::server: Control channel established service=bitwarden"' , timeout=10)

      # Check we have a client control channel
      lab.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "rathole::client: Control channel established"' , timeout=10)

    with subtest("Test actual"):
      # Wait for actual to start
      wait_for_actual_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "Listening on :::5006..."'
      lab.wait_until_succeeds(wait_for_actual_cmd, timeout=60)

      # Test login page
      output = vps.succeed("curl --silent actual.ahayzen.com:80/login")
      assert "Actual" in output, f"'{output}' does not contain 'Actual'"

    with subtest("Test bitwarden"):
      # Wait for bitwarden to start
      wait_for_bitwarden_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "INFO success: nginx entered RUNNING state"'
      lab.wait_until_succeeds(wait_for_bitwarden_cmd, timeout=60)

      # Test login page
      output = vps.succeed("curl --silent bitwarden.ahayzen.com:80/#/login")
      assert "Bitwarden" in output, f"'{output}' does not contain 'Bitwarden'"

    #
    # Test that we can backup lab
    #

    with subtest("Access hostkey"):
      lab.wait_for_open_port(8022, timeout=30)
      # Ensure we allow the host key
      backup.succeed("ssh -vvv -p 8022 -o StrictHostKeyChecking=accept-new headless@lab exit")

    with subtest("Attempt to run lab backup"):
      backup.succeed("mkdir -p /tmp/backup-root-lab")

      # Check that the permissions are correct
      lab.succeed("ls -nd /var/lib/docker-compose-runner/actual/data/server-files/account.sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      lab.succeed("ls -nd /var/lib/docker-compose-runner/bitwarden/config/vault.db | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Trigger a snapshot
      dayofweek = datetime.datetime.today().strftime('%w')
      lab.succeed("systemctl start periodic-daily.service")

      # Run the backup
      backup.succeed("/etc/ahayzen.com/backup.sh lab /etc/ssh/test_ssh_id_ed25519 headless@lab /tmp/backup-root-lab")

      # Check volumes are appearing
      backup.succeed("test -d /tmp/backup-root-lab/docker-compose-runner/actual/data")
      backup.succeed("test -d /tmp/backup-root-lab/docker-compose-runner/bitwarden/config")

      # Check that known files exist and permissions are correct
      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/actual/data/server-files/account-snapshot-" + dayofweek + ".sqlite")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/actual/data/server-files/account-snapshot-" + dayofweek + ".sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/actual/data/server-files/account.sqlite")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/actual/data/server-files/account.sqlite | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/bitwarden/config/vault-snapshot-" + dayofweek + ".db")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/bitwarden/config/vault-snapshot-" + dayofweek + ".db | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root-lab/docker-compose-runner/bitwarden/config/vault.db")
      backup.succeed("ls -nd /tmp/backup-root-lab/docker-compose-runner/bitwarden/config/vault.db | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

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
