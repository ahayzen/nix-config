# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, ... }:
{
  systemd.services."periodic-daily" = {
    # Snapshot of any databases so that we don't download a partial database
    #
    # This uses the online backup API as described in how to backup while transactions are active
    # https://www.sqlite.org/howtocorrupt.html#_backup_or_restore_while_a_transaction_is_active
    script = ''
      /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/actual/data/server-files/account.sqlite ".backup /var/lib/docker-compose-runner/actual/data/server-files/account-snapshot-$(date +%w).sqlite"
      /run/wrappers/bin/sudo --user=unpriv ${pkgs.sqlite}/bin/sqlite3 /var/lib/docker-compose-runner/bitwarden/config/vault.db ".backup /var/lib/docker-compose-runner/bitwarden/config/vault-snapshot-$(date +%w).db"
    '';
  };
}
