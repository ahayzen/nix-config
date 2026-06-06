<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Networking

There are multiple different possible approaches to handle networking for to the home lab.

  * Reverse proxy between Lab and VPS
  * Split DNS
  * VPN

## Reverse Proxy

Reverse proxy on VPS and each service tunneled.

```
External Device ---> Public DNS ---> VPS (caddy HTTPS termination) --- tunnel ---> Lab (HTTP service)
Internal Device ---> ^^
```

> Note the internal device still goes to the internet and back

## Split DNS

Reverse proxy on both VPS and Lab, each service is tunneled, and DNS on the LAN redirects.

```
External Device ---> Public DNS   ---> VPS (caddy HTTPS termination?) --- tunnel ---> Lab (HTTPS service)
Internal Device ---> Internal DNS ---> Lab (HTTPS service)
```

> Note this requires DNS-01 or DNS-PERSIST-01 for Lab HTTPS certificates

## VPN

Reverse proxy on both VPS and Lab, VPN hosted on VPS, and either DNS on the LAN redirects or clients use VPN.

```
External Device ---> Public DNS ---> VPN ---> VPS (VPN server) --- VPN ---> Internal DNS ---> Lab (HTTPS Service)
Internal Device ---> Internal DNS ---> Lab (HTTPS Service)
```

> Note this requires DNS-01 or DNS-PERSIST-01 for Lab HTTPS certificates

> Note for internal devices the internal DNS needs to unset the vpn domain so that the VPN connection is disabled

> Note services now require VPN to be accessed

## Double VPN

Reverse proxy on both VPS and Lab, VPN hosted on Lab, second VPN for tunneling, and either DNS on the LAN redirects or clients use VPN.

```
External Device ---> Public DNS ---> VPS (caddy HTTPS termination) ---> VPN tunnel ---> Lab (HTTPS Service)
Internal Device ---> Internal DNS ---> Lab (HTTPS Service)

External Device ---> VPN ---> Public DNS ---> VPS (caddy HTTPS termination) ---> VPN tunnel ---> Lab (VPN Server) ---> VPN DNS ---> Lab (HTTPS Service)
External Device ---> VPN ---> Internal DNS ---> Lab (VPN Server) ---> VPN DNS ---> Lab (HTTPS Service)
```

This allows for the VPN to remain connected and for services to be both public and private.

To implement this `socat` could be used in a container to bounce connections between wg-easy and the services.
Then caddy/traefix bind can be used to limit the IP ranges of public vs private services.

Likely these are useful to impement this:

  - https://oslks.medium.com/how-i-exposed-my-home-server-behind-cgnat-securely-without-port-forwarding-d54c52e640c6
  - https://github.com/ondrasalek/cgnat-vps-gateway
  - https://caddyserver.com/docs/caddyfile/directives/bind

## Phases

### Current

  * service.domain.com exists on VPS
  * http service exists on Lab
  * http tunnel between

### Phase 1 - Split DNS

Add Caddy to Lab using a wildcard for the services and DNS-01 / DNS-PERSIST-01.

Add internal DNS to point to Lab.

  * service.domain.com exists on VPS
  * https service exists on Lab
  * https tunnel between
  * internal DNS points directly to Lab for service domains

### Phase 2 - VPN

Add VPN to VPS
Add Lab to VPN network
Add DNS to VPN network

  * service.domain.com exists on VPS
  * https service exists on Lab
  * https tunnel between
  * internal DNS points directly to Lab for service domains
  * internal DNS disables VPN domain
  * VPN hub is on VPS
  * Lab is spoke on VPN
  * DNS on VPN network points to Lab for services

### Phase 3 - Wildcard

Removal of tunnel
Move of services to *.internal.domain.com

  * only vpn.domain.com is public
  * https service exists on Lab
  * internal DNS disables VPN domain
  * VPN hub is on VPS
  * Lab is spoke on VPN
  * DNS on VPN network points to Lab for *.internal.domain.com

### No phases

* Move monitoring to beszel
* Remove homepage and have static page
* Add wireguard easy to VPS
* Add Lab to wireguard easy
* Add CoreDNS onto VPN network
* Add a test Caddy server to Lab using wildcard DNS certs
* Add DNS entry to block VPN internally
* Move services to *.internal.domain.com
