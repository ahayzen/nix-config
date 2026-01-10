<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Services

General requirements for services.

## Must

  * Docker permissions (no network host or docker socket mount)
  * OSI approved license
  * Web interface or similar to avoid 10yr problem if apps aren't relevant

## Should

  * Use Go/Rust/C# for compiled or Python/TypeScript or similar for interpreted
  * Use sqlite for database or no database
  * Be one container image