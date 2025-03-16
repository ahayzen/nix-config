<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Data

Data is combined to one centtral location and then snapshot from there.

Manually stored items

  - Camera
  - Documents
  - [Music](./music.md)
  - [Movies](./movies.md)
  - Recordings (edited videos)
  - [TV shows](./shows.md)
  - User

Automatically stored items

  - Apps (data with no category eg profile images)
  - Backups (snapshots of databases /var/lib)
  - Photostream

## Folder structure

Each location has two kinds of data "cache" or "data",
cache data is not backed up and is used for live databases or generated data.

This means that each machine running services has the following folders used by containers.

```
/var/cache/docker-compose-runner/
/var/lib/docker-compose-runner/
```

Live databases are stored in /var/cache and periodic snapshots are saved into /var/lib.
This allows for tooling to periodically backup /var/lib without live databases changing.

The main pool of data is then structured as follows

```
/backup
  /restic
    /<repo>
/cache
  /<service>
/data
  /app/<service>/
  /backup/<device>/<latest|outdated>/
  /camera/<device>/<year>/<album/month>/
  /documents/
  /music/<artist>/<album>/
  /movies/<movie>/
  /photostream/<device>/<year>/
  /recordings/<device>/<year>/
  /shows/<show>/<series>/
  /user/<user>/
```

## 3-2-1-1-0

 - 3 copies of data
 - 2 different media
 - 1 offsite
 - 1 offline
 - 0 errors

Restic push backups to lab and backblaze.

Rsync (should synology / cold storage use restic?) pull backups from lab to synology and cold storage.

```
# Push backups
Lab Pool -> Restic -> Lab
                   -> Backblaze
# Pull backups
Lab Pool <- rsync  <- Synology
                   <- Cold storage (manual)
```

Common scenarios and where data would still be accessible.

| Scenario | Lab Pool | Lab Backup | B2 | Synology | Cold Storage |
|----------|----------|------------|----|----------|--------------|
| Deleted file | N | Y | Y | Y | Y |
| Ransomware | N | N | Y | Y | Y |
| Power surge | N | N | Y | N | Y |
| Fire | N | N | Y | N | N |

Scenarios related to a technology attack and where data would still be accessible.

| Scenario | Lab Pool | Lab Backup | B2 | Synology | Cold Storage |
|----------|----------|------------|----|----------|--------------|
| Snapraid | N | N | Y | Y | Y |
| Github/Flake | N | N | N | Y | Y |
| NixOS | N | N | N | Y | Y |
| Restic | Y | N | N | Y | Y |
| Rsync | Y | Y | Y | N | N |
| XFS | N | N | Y | Y | Y |

> Assuming that Cold storage uses exFAT/ext4 and rsync

TODO: have a page for snapraid/mergerfs and how to restore etc
