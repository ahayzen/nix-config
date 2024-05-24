#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

set -e

#
# backup <machine-name> <identity-file> <user@host> <backup-dest>
#

SSH_PORT=8022

# Check that rsync exists
if [ ! -x "$(command -v rsync)" ]; then
    echo "rsync command not found, cannot backup"
    exit 1
fi

HEADLESS_SYSTEM=false
IDENTITY_FILE=$2
if [ ! -f "$IDENTITY_FILE" ]; then
    echo "Failed to find identity file"
    exit 1
fi
USER_HOST=$3

# Check that the machine name is known
#
# Snapshot of any databases so that we don't download a partial database
#
# This uses the online backup API as described in how to backup while transactions are active
# https://www.sqlite.org/howtocorrupt.html#_backup_or_restore_while_a_transaction_is_active
case $1 in
    lab)
        HEADLESS_SYSTEM=true
        ssh -p "$SSH_PORT" "$USER_HOST" "sudo --user=unpriv sqlite3 /var/lib/docker-compose-runner/actual/data/server-files/account.sqlite '.backup /var/lib/docker-compose-runner/actual/data/server-files/account-snapshot.sqlite'"
        ssh -p "$SSH_PORT" "$USER_HOST" "sudo --user=unpriv sqlite3 /var/lib/docker-compose-runner/bitwarden/config/vault.db '.backup /var/lib/docker-compose-runner/bitwarden/config/vault-snapshot.db'"
        ;;
    vps)
        HEADLESS_SYSTEM=true
        ssh -p "$SSH_PORT" "$USER_HOST" "sudo --user=unpriv sqlite3 /var/lib/docker-compose-runner/wagtail-ahayzen/db/db.sqlite3 '.backup /var/lib/docker-compose-runner/wagtail-ahayzen/db/db-snapshot.sqlite3'"
        ssh -p "$SSH_PORT" "$USER_HOST" "sudo --user=unpriv sqlite3 /var/lib/docker-compose-runner/wagtail-yumekasaito/db/db.sqlite3 '.backup /var/lib/docker-compose-runner/wagtail-yumekasaito/db/db-snapshot.sqlite3'"
        ;;
    *)
        echo "Unknown machine name"
        exit 1
        ;;
esac

# Check that the target folder exists
USER_DEST=$4
if [ ! -d "$USER_DEST" ]; then
    echo "Failed to find backup target"
    exit 1
fi
BACKUP_DEST="$USER_DEST"

# Prepare the rsync args
RSYNC_ARGS=(--archive --human-readable --ignore-times --numeric-ids --partial --progress --rsh="ssh -i $IDENTITY_FILE -p $SSH_PORT" --rsync-path="sudo rsync")

# This is a normal headless system
if [ $HEADLESS_SYSTEM ]; then
    export DOCKER_COMPOSE_RUNNER_DEST="$BACKUP_DEST/docker-compose-runner/"
    mkdir -p "$DOCKER_COMPOSE_RUNNER_DEST"

    # Backup all of the docker data
    sudo "$(command -v rsync)" "${RSYNC_ARGS[@]}" "$USER_HOST:/var/lib/docker-compose-runner/" "$DOCKER_COMPOSE_RUNNER_DEST"
fi

# Ensure the filesystem is synced
sync

echo "Backup complete!"
date
