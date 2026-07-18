<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Wireguard

## IP address range

An IP address range needs to be picked that avoids colliding with other ranges in your network.
This can become a problem when using public WiFi or mobile networks that use private IP addresses.

https://en.wikipedia.org/wiki/Private_network
https://en.wikipedia.org/wiki/List_of_reserved_IP_addresses

To avoid colliding with an IPv4 network consider using a range with low usage from these statistics.
https://blog.benjojo.co.uk/post/picking-unused-rfc1918-ip-space

Note that subnets can be smaller than a full range so you could pick for example
`10.0.0.128/25` instead of `/24` which would give you an unusual less common range.

For IPv6 ULA range is likely fine
https://en.wikipedia.org/wiki/Unique_local_address

## MTU

A normal TCP packet size is around 1500, then consider around 80 as overhead for each layer of wireguard.

This means that the first wireguard layer should use a MTU of 1420, the second 1340, and so on.

## `wg-easy`

Change the password after initial login, this can be done via the CLI with similar to the following
```console
docker compose exec -it wg-easy cli db:admin:reset
```
https://wg-easy.github.io/wg-easy/v15.3/guides/cli/#reset-password

In the admin panel interface section, set MTU to the rules above and persistent keepalive to 25s.

Update the hooks to use nftables as wg-easy still uses iptables, as seen in the podman documentation
https://wg-easy.github.io/wg-easy/v15.3/examples/tutorials/podman-nft/#edit-hooks
