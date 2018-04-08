DomotiGa
========

This image allow to run a headless instance of domotiga (https://www.domotiga.nl/).
Domotiga is an OSS Home Automation for Linux.

Ports exposed
-------------

- `9009` : XML-RPC Server
- `19009/udp` : XML-RPC UDP Broadcasts
- `9090` : JSON-RPC Server

Volumes
-------

`/domotiga/config`
`/domotiga/logs`
`/domotiga/rrd`
`/var/lib/mysql`

Run
---

Launch the DomotiGa docker container with the following command:

```
docker run [-d] \
    --name=domotiga \
    --privileged \
    -p 5800:5800 \
    -p 9090:9090 \
    -v /docker/domotiga/config:/domotiga/config \
    -v /docker/domotiga/logs:/domotiga/logs \
    -v /docker/domotiga/rrd:/domotiga/rrd \
    -v /docker/domotiga/mysql:/var/lib/mysql \
    ualex73/domotiga
```

Where:
  - `/docker/domotiga/config`: This is where DomotiGa stores its configuration, including OpenZWave configuration and logs, needing persistency.
  - `/docker/domotiga/log`: This location contains DomotiGa log files, needed persistency.
  - `/docker/domotiga/rrd`: This location contains DomotiGa rrd files (if enabled), needed persistency.
  - `/docker/domotiga/mysql`: This location contains MySQL database for DomotiGa, needed persistency.
  - `9090`: JSON-RPC Server port of DomotiGa.
  - `privledged` - Gives access to all devices, includes serial devices. This is less secure, but makes configuration easier. Use exact device mapping if you don't want to use privledged.

Browse to `http://your-host-ip:5800` to access the DomotiGa GUI.

