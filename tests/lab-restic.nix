# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

#
# Test the following
#
# Lab
# - restic snapshots

(import ./lib.nix) {
  name = "lab-restic-test";
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
          restic = true;
        };
      };

      # Extra packages for the test
      environment.systemPackages = [ pkgs.curl ];

      virtualisation = {
        cores = 2;
        # Increase so we can fit docker images
        diskSize = 2 * 1024;
        memorySize = 2 * 1024;
      };
    };
  };

  testScript = ''
    start_all()

    with subtest("Ensure docker starts"):
      lab.wait_for_unit("docker-compose-runner", timeout=120)

    with subtest("Test restic"):
      # Wait for restic to start
      wait_for_restic_init_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "created restic repository"'
      lab.wait_until_succeeds(wait_for_restic_init_cmd, timeout=60)

      # Create some files
      lab.succeed("touch /mnt/pool/data/a1")
      lab.succeed("chown 2000:2000 /mnt/pool/data/a1")
      lab.succeed("touch /mnt/pool/data/b2")
      lab.succeed("chown 2000:2000 /mnt/pool/data/b2")

      # Check that they have the right permissions
      lab.succeed("test -e /mnt/pool/data/a1")
      lab.succeed("ls -nd /mnt/pool/data/a1 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      lab.succeed("test -e /mnt/pool/data/b2")
      lab.succeed("ls -nd /mnt/pool/data/b2 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Create a snapshot
      lab.succeed("systemctl start restic-local-backup.service")

      # Delete one of the files
      lab.succeed("rm /mnt/pool/data/b2")
      lab.succeed("test -e /mnt/pool/data/a1")
      lab.fail("test -e /mnt/pool/data/b2")

      # Restore from the a snapshot
      restic_image_id = lab.succeed("docker images -q ghcr.io/restic/restic").strip()
      assert restic_image_id != "", "restic image id is empty"
      lab.succeed("mkdir -m 0750 -p /mnt/restore")
      lab.succeed("chown unpriv:unpriv /mnt/restore")
      lab.succeed("docker run --rm --env=RESTIC_PASSWORD_FILE=/etc/restic/password --volume=/etc/restic/password:/etc/restic/password:ro --volume=/mnt/restore:/mnt/restore:rw --volume=/mnt/pool/backup/restic:/mnt/pool/backup/restic:rw " + restic_image_id + " restore --repo /mnt/pool/backup/restic --host restic-local --target /mnt/restore latest")
      lab.succeed("rm -rf /mnt/pool/data/*")
      lab.succeed("mv /mnt/restore/mnt/pool/data/* /mnt/pool/data/")

      # Check the file is restored
      lab.succeed("test -e /mnt/pool/data/a1")
      lab.succeed("ls -nd /mnt/pool/data/a1 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")
      lab.succeed("test -e /mnt/pool/data/b2")
      lab.succeed("ls -nd /mnt/pool/data/b2 | awk 'NR==1 {if ($3 == 2000) {exit 0} else {exit 1}}'")

      # Check that restarting docker doesn't init again
      lab.succeed("systemctl restart docker-compose-runner")

      # Wait for restic cat config (as we should see this instead of init)
      wait_for_restic_cat_cmd = 'journalctl --boot --no-pager --quiet --unit docker.service --grep "repository .* opened"'
      lab.wait_until_succeeds(wait_for_restic_cat_cmd, timeout=60)

    with subtest("General metrics (lab)"):
      print(lab.succeed("cat /etc/hosts"))
      print(lab.succeed("ps auxf"))
      print(lab.succeed("free -h"))
      print(lab.succeed("df -h"))
      print(lab.succeed("docker images"))
      print(lab.succeed("docker stats --no-stream"))
  '';
}
