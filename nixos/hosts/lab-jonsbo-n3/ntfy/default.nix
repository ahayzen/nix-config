# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ config, options, lib, pkgs, ... }:
{
  age.secrets = lib.mkIf (!config.ahayzen.testing) {
    ntfy_lab_jonsbo_n3_token = {
      file = ../../../../secrets/ntfy_lab_jonsbo_n3_token.age;
      mode = "0644";
      owner = "unpriv";
      group = "unpriv";
    };
  };

  environment.etc = {
    "ntfy/token".source =
      if config.ahayzen.testing
      then ./ntfy_token.vm
      else config.age.secrets.ntfy_lab_jonsbo_n3_token.path;
  };
}
