#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

set -e

mariadb-dump \
  --user="${MYSQL_USER}" \
  --password="${MYSQL_PASSWORD}" \
  "${MYSQL_DATABASE}" > /var/lib/docker-compose-runner/bookstack/database/bookstack-database.sql

mariadb-dump \
  --user="${MYSQL_USER}" \
  --password="${MYSQL_PASSWORD}" \
  "${MYSQL_DATABASE}" > /var/lib/docker-compose-runner/bookstack/database/bookstack-database-snapshot-$(date +%w).sql
