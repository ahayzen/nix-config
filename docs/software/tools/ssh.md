<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# SSH

## Create Key

For ed25519

```console
ssh-keygen -f ~/.ssh/id_ed25519 -t ed25519
```

For RSA

```console
ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 4096
```

> ed25519 should be preferred

## Changing Password

Update a password using

```console
ssh-keygen -f ~/.ssh/id_ed25519 -p
```

## Allowed Signers

Trusted SSH signer public keys can be added to the `~/.ssh/allowed_signers` file.

```console
echo "user@example.com ssh-ed25519 pubkey" >> ~/.ssh/allowed_signers
```
