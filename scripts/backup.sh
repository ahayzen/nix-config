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
case $1 in
    lab)
        HEADLESS_SYSTEM=true
        ;;
    vps)
        HEADLESS_SYSTEM=true
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
RSYNC_ARGS=(--archive --checksum --human-readable --ignore-times --numeric-ids --partial --progress --rsh="ssh -i $IDENTITY_FILE -p $SSH_PORT" --rsync-path="sudo rsync")

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
