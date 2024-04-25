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
        "127.0.0.1" = [ "ahayzen.com" ];
      };

      # Allow test ssh authentication
      users.users.headless.openssh.authorizedKeys.keyFiles = [
        ./files/test_ssh_id_ed25519.pub
      ];
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

      # Setup IdentityFile for vps
      programs.ssh.extraConfig = builtins.readFile ./files/ssh_config;
    };
  };

  testScript = ''
    start_all()

    wait_for_wagtail_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "\[INFO\] Listening at: http:\/\/0\.0\.0\.0:8080"'

    #
    # Test that the VPS boots and shows wagtail admin
    #

    with subtest("Ensure docker starts and wagtail admin works"):
      # Wait for docker runner
      vps.wait_for_unit("docker-compose-runner", timeout=90)

      # Wait for caddy to start
      vps.wait_for_open_port(80, timeout=60)

      # Wait for wagtail to start
      vps.wait_until_succeeds(wait_for_wagtail_cmd, timeout=60)

      # Test that admin page exists
      output = vps.succeed("curl --silent ahayzen.com:80/admin/login/?next=/admin/")
      assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"

      # Test that wagtail port is not open externally
      vps.fail("curl --silent ahayzen.com:8080")

    #
    # Test that we can backup and restore the VPS
    #

    with subtest("Access hostkey"):
        vps.wait_for_open_port(22, timeout=30)
        # Ensure we allow the host key
        backup.succeed("ssh -vvv -o StrictHostKeyChecking=accept-new headless@vps exit")

    with subtest("Attempt to run a backup"):
      backup.succeed("mkdir -p /tmp/backup-root")

      # Check that the permissions are correct
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Run the backup
      backup.succeed("/etc/ahayzen.com/backup.sh vps headless@vps /tmp/backup-root")

      # Check volumes are appearing
      backup.succeed("test -d /tmp/backup-root/docker-compose-runner/caddy/persistent")
      backup.succeed("test -d /tmp/backup-root/docker-compose-runner/caddy/config")
      backup.succeed("test -d /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/db")
      backup.succeed("test -d /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/media")
      backup.succeed("test -d /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/static")

      # Check that known files exist and permissions are correct
      backup.succeed("test -e /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/db/db-snapshot.sqlite3")
      backup.succeed("ls -nd /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/db/db-snapshot.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      backup.succeed("test -e /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3")
      backup.succeed("ls -nd /tmp/backup-root/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

    with subtest("Attempt to run a restore"):
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
      backup.succeed("/etc/ahayzen.com/restore.sh vps headless@vps /tmp/restore-root/test-page")

      # Check that the permissions are still correct
      vps.succeed("ls -nd /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Wait for services to restart and second occurance of Listening at
      vps.wait_for_unit("docker-compose-runner", timeout=90)
      vps.wait_for_open_port(80, timeout=60)
      vps.wait_until_succeeds(wait_for_wagtail_cmd + " | wc -l | awk '{if ($1 > 1) {exit 0} else {exit 1}}'", timeout=60)

      # Check the home does contain restore key
      output = vps.succeed("curl --silent ahayzen.com:80/")
      assert "Restore Unit Test" in output, f"'{output}' does not contain 'Restore Unit Test'"
  '';
}
