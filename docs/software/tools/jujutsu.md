<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Enabling features

## Signed Off By

```toml
[templates]
commit_trailers = '''
format_signed_off_by_trailer(self)'''
```

## Digital Signing SSH

```toml
[signing]
behavior = "own"
backend = "ssh"
key = "~/.ssh/id_ed25519.pub"
backends.ssh.allowed-signers = "~/.ssh/allowed_keys"

# Only sign when pushing not making changes locally
# [git]
#sign-on-push = true

[ui]
show-cryptographic-signatures = true
```

* [SSH Signings](https://docs.jj-vcs.dev/latest/config/#ssh-signing)
* [Automatically Signing Commits](https://docs.jj-vcs.dev/latest/config/#automatically-signing-commits)
