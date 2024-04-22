#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

set -e

#
# backup <machine-name> <user@host> <backup-dest>
#

# Check that rsync exists
if [ ! -x "$(command -v rsync)" ]; then
    echo "rsync command not found, cannot backup"
    exit 1
fi
RSYNC_ARGS=(--archive --human-readable --ignore-times --numeric-ids --partial --progress --rsync-path="sudo rsync")

HEADLESS_SYSTEM=false
USER_HOST=$2

# Check that the machine name is known
case $1 in
    vps)
        HEADLESS_SYSTEM=true
        ;;
    *)
        echo "Unknown machine name"
        exit 1
        ;;
esac

# Check that the target folder exists
USER_DEST=$3
if [ ! -d "$USER_DEST" ]; then
    echo "Failed to find backup target"
    exit 1
fi
BACKUP_DEST="$USER_DEST"

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
