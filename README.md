DomotiGa
========

This image allow to run a headless instance of DomotiGa (https://www.domotiga.nl/). It requires an external MySQL server, this can be for example a MySQL Docker container (see for example the docker-compose.yaml at the end).

Ports exposed
-------------

- `9090` : JSON-RPC Server
- `19009/udp` : XML-RPC UDP Broadcasts

Volumes
-------

`/domotiga/config`
`/domotiga/logs`
`/domotiga/rrd`

Run
---

Launch the DomotiGa docker container with the following command:

```
docker run [-d] \
    --name=domotiga \
    --privileged \
    -p 5800:5800 \
    -p 9090:9090 \
    -e MYSQL_HOST=192.168.1.1 \
    -v /docker/domotiga/config:/domotiga/config \
    -v /docker/domotiga/logs:/domotiga/logs \
    -v /docker/domotiga/rrd:/domotiga/rrd \
    ualex73/domotiga
```

Where:
  - `/docker/domotiga/config`: This is where DomotiGa stores its configuration, including OpenZWave configuration and logs, needing persistency.
  - `/docker/domotiga/log`: This location contains DomotiGa log files, needed persistency.
  - `/docker/domotiga/rrd`: This location contains DomotiGa rrd files (if enabled), needed persistency.
  - `9090`: JSON-RPC Server port of DomotiGa.
  - `privledged` - Gives access to all devices, includes serial devices. This is less secure, but makes configuration easier. Use exact device mapping if you don't want to use privledged.


Browse to `http://your-host-ip:5800` to access the DomotiGa GUI.


Docker-compose.yaml Example
---
```
version: '3'

services:

  mysql_domotiga:
    container_name: mysql_domotiga
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    restart: unless-stopped
    volumes:
      - /docker/mysql_domotiga:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=example

  domotiga:
    container_name: domotiga
    image: ualex73/domotiga:latest
    restart: unless-stopped
    privileged: true
    links:
      - mysql_domotiga
    ports:
      - 5800:5800
      - 9090:9090
    environment:
      - TZ=Europe/Amsterdam
      - MYSQL_HOST=mysql_domotiga
    volumes:
      - /docker/domotiga/config:/domotiga/config
      - /docker/domotiga/logs:/domotiga/logs
      - /docker/domotiga/rrd:/domotiga/rrd
```

