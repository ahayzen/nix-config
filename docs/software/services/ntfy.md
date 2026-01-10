<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Ntfy

## User management

Adding a user to listen to notifications

```bash
ntfy user add username
ntfy access username * ro
```

Adding a user to publish notifications

```bash
ntfy user add username
ntfy access username * wo
```

Creating a token to use for a user

```bash
ntfy token add username
```

