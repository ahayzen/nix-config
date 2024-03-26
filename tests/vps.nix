# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

(import ./lib.nix) {
  name = "vps test";
  nodes = {
    machine = { self, pkgs, ... }: {
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
    };
  };

  testScript = ''
    start_all()

    # Wait for docker runner
    machine.wait_for_unit("docker-compose-runner", timeout=90)

    # Wait for caddy to start
    machine.wait_for_open_port(80, timeout=60)

    # Wait for wagtail to start
    machine.wait_until_succeeds('journalctl --boot --no-pager --quiet --unit docker.service --grep "\[INFO\] Listening at: http:\/\/0\.0\.0\.0:8080"', timeout=60)

    # Test that admin page exists
    output = machine.succeed("curl --silent ahayzen.com:80/admin/login/?next=/admin/")
    assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"

    # Test that wagtail port is not open externally
    machine.fail("curl --silent ahayzen.com:8080")
  '';
}
