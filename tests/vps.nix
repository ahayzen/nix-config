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
    };
  };

  testScript = ''
    import time

    start_all()

    # Wait for docker runner
    machine.wait_for_unit("docker-compose-runner")

    # Wait for caddy to start
    machine.wait_for_open_port(80)

    # Wait long enough for wagtail migrations
    #
    # TODO: can we instead wait for "Listening at" from the syslog?
    attempts = 30
    while attempts:
      (status, output) = machine.execute("curl --silent localhost:80/admin/login/?next=/admin/")
      if "Sign in" in output:
        break
      time.sleep(1)
      attempts -= 1

    # Test that admin page exists
    output = machine.succeed("curl --silent localhost:80/admin/login/?next=/admin/")
    assert "Sign in" in output, f"'{output}' does not contain 'Sign in'"
  '';
}
