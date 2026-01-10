<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Temporary port

To allow for exposing a port on an internal container temporarily the following can be used.

```console
nixos-firewall-tool open tcp 9999

sudo docker create --name=tmp-proxy -p 9999:9999 -it --rm gogost/gost -L tcp://0.0.0.0:9999/containername:port
sudo docker network connect docker-compose-runner_group-proxy tmp-proxy
sudo docker network connect docker-compose-runner_lan tmp-proxy
sudo docker start -i tmp-proxy

nixos-firewall-tool reset
````
