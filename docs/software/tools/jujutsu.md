<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Jujutsu

## Bookmarks

```toml
[remotes.origin]
# Track any bookmarks according to pattern (eg alice/*)
auto-track-bookmarks = "*"
# Track create or set bookmarks according to pattern
auto-track-created-bookmarks = "*"
```

https://docs.jj-vcs.dev/latest/config/#automatic-tracking-of-bookmarks

## Commit Message

### Signed Off By

Useful when using DCO (Developer Certificate of Origin)

```toml
[templates]
commit_trailers = '''
format_signed_off_by_trailer(self)'''
```

## Gerrit

General repo configuration

```toml
[gerrit]
# Set the remote for gerrit pushes and the branch
default-remote = "gerrit"
default-remote-branch = "main"

[templates]
# Enable sign off and change id
commit_trailers = '''
format_signed_off_by_trailer(self)
++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))'''
```

Different push commands

```console
jj gerrit upload
# Upload ancestors of B but not of A
jj gerrit upload -r A..B
```

## Multiple remotes

```toml
[git]
fetch = ["upstream", "origin"]
push = "origin"
```

> Ensure you set `revset-aliases.trunk()` to `main@origin` too

## Private Commits

Commits with matching descriptions and their descendants will not be pushed to the remote.

```toml
[git]
private-commits = "description('wip:*') | description('private:*')"
```

> To push descendants either use `-r rev` or rebase the commit before pushing

Alternatively use a merge the private commit into your branch.

```console
# Create a merge commit between the feature and private commit
jj new @ scratch
# Create a new commit before the private commit or squash as usual
jj new --insert-before @- --insert-after @--
```

https://docs.jj-vcs.dev/latest/faq/#how-can-i-avoid-committing-my-local-only-changes-to-tracked-files

## Signing

Digital signing using SSH

```toml
[signing]
behavior = "own"
backend = "ssh"
key = "~/.ssh/id_ed25519.pub"
backends.ssh.allowed-signers = "~/.ssh/allowed_signers"

# Only sign when pushing not making changes locally
# [git]
#sign-on-push = true

[ui]
show-cryptographic-signatures = true
```

* [SSH Signings](https://docs.jj-vcs.dev/latest/config/#ssh-signing)
* [Automatically Signing Commits](https://docs.jj-vcs.dev/latest/config/#automatically-signing-commits)
