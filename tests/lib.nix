# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

test:
{ lib, pkgs, inputs, self, outputs }:
let
  inherit (pkgs) lib;
  nixos-lib = import (pkgs.path + "/nixos/lib") { };
in
(nixos-lib.runTest {
  hostPkgs = pkgs;
  defaults.documentation.enable = lib.mkDefault false;
  node.specialArgs = { inherit inputs self outputs; };
  imports = [ test ];
}).config.result
