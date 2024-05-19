#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

set -e

#
# restore <machine-name> <identity-file> <user@host> <restore-source>
#

SSH_PORT=8022

# Check that rsync exists
if [ ! -x "$(command -v rsync)" ]; then
    echo "rsync command not found, cannot restore"
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
    vps)
        HEADLESS_SYSTEM=true
        ;;
    *)
        echo "Unknown machine name"
        exit 1
        ;;
esac

# Check that the source folder exists
USER_SRC=$4
if [ ! -d "$USER_SRC" ]; then
    echo "Failed to find restore source"
    exit 1
fi
RESTORE_SRC="$USER_SRC"

# Prepare the rsync args
RSYNC_ARGS=(--archive --human-readable --ignore-times --numeric-ids --partial --progress --rsh="ssh -i $IDENTITY_FILE -p $SSH_PORT" --rsync-path="sudo rsync")

# This is a normal headless system
if [ $HEADLESS_SYSTEM ]; then
    export DOCKER_COMPOSE_RUNNER_SRC="$RESTORE_SRC/docker-compose-runner/"
    if [ ! -d "$DOCKER_COMPOSE_RUNNER_SRC" ]; then
        echo "Failed to find docker-compose-runner data to restore"
        exit 1
    fi

    # Stop services as we are about to mutate data
    ssh -p "$SSH_PORT" "$USER_HOST" sudo systemctl stop docker-compose-runner.service

    # Restore all of the docker data
    sudo "$(command -v rsync)" "${RSYNC_ARGS[@]}" "$DOCKER_COMPOSE_RUNNER_SRC" "$USER_HOST:/var/lib/docker-compose-runner/"

    # Restart services
    ssh -p "$SSH_PORT" "$USER_HOST" sudo systemctl start docker-compose-runner.service
fi

echo "Restore complete!"
date
