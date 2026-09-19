<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Archive

For cold-storage or archiving there are a few options

  * Using an offline HDD
  * Using [Blu-ray disks](./../guides/backup/blu-ray.md)

## Sources

Non-recoverable data (eg personal data not music / movies) are found in the following locations.

Year based data

```
/camera/<year>/
/photostream/<user>/<year>/
/recordings/<year>/
/user/<user>/Camera/<year>/
```

> The following command can be used to discover folder sizes `sudo du --human-readable --max-depth=2 /camera /photostream /recordings /user/<user>/Camera | sort -k2`

Other data

```
/app/
/backup/
/documents/
/files/
/user/<user>/
````
