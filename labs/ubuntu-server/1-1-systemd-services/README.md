# Ubuntu Server 1.1: Services with systemd

Stopping a service from starting, masking it, writing your own unit, and
changing it with a drop-in.

## Before you start

The lab doesn't install anything: installing nginx is part of task 1. It
checks that nothing listens on port 8080 yet and that there's no
`hello.service`.

## Tasks

1. Install nginx, stop it from starting at boot, then make sure it can't be
   started at all. Undo both, so nginx is enabled and running again.
2. Write a service `hello.service` that runs `/usr/bin/python3 -m
   http.server 8080` from `/tmp` as the user `nobody`, enabled at boot.
   `curl -s localhost:8080 | head -1` prints HTML.
3. With a drop-in, make `hello` restart 3 seconds after it fails. After
   `sudo kill -9` of its main PID, it's active again within a few seconds.

## Hints

- `systemctl disable`, `mask`, `unmask`, `enable --now`; `is-enabled`,
  `is-active`.
- A unit in `/etc/systemd/system/` with `User=`, `WorkingDirectory=`,
  `ExecStart=` and `[Install]` `WantedBy=multi-user.target`;
  `systemctl daemon-reload`, `enable --now`. `ps -o user= -C python3`.
- `sudo systemctl edit hello`, `Restart=on-failure`, `RestartSec=3`;
  `systemctl cat hello`, `systemctl show hello -p MainPID`.
