# LFCS 1.7: Containers

Running a container with a port and a read-only bind mount, a container
as a service with Quadlet, a rootless container that starts at boot,
building an image, and configuring Docker.

## Before you start

The VM needs internet access to pull images. The lab installs Podman and
creates user `alice` (password `Lab-Pass-1`). Docker isn't installed: that's
part of task 5. Docker Hub limits anonymous pulls; if you hit the limit,
`mirror.gcr.io/library/nginx` is the same image.

## Tasks

1. As root, run nginx in a container named `web` on host port 8080,
   serving `/srv/web` read-only. `curl localhost:8080` returns the
   `index.html` you put in `/srv/web`. On the RHEL-family VM, keep SELinux
   enforcing.
2. Make that container start at every boot with Quadlet, as `web.service`.
   Remove the container from the previous task first (`podman rm -f web`);
   Quadlet names its container `systemd-web` unless you set
   `ContainerName=web`. After a reboot, `systemctl is-active web` prints
   `active` and the page still loads.
3. As `alice`, run a rootless container that keeps its data in a named
   volume and starts at boot. After a reboot, without logging in as
   `alice`,
   `sudo -u alice XDG_RUNTIME_DIR=/run/user/$(id -u alice) podman ps`
   shows it running.
4. As root, build an image from a Containerfile that serves a static page,
   tag it `site:1.0`, and run it with `-e` setting a variable the page
   doesn't need. Keep the container.
5. Install Docker, set its log driver to `journald`, and restart it.

## Hints

- `podman run -d --name -p -v SRC:DST:ro,Z`, `podman port`, `podman inspect`.
- A `.container` file in `/etc/containers/systemd/`, `systemctl
  daemon-reload`; the `[Install]` section makes it start at boot.
- `~/.config/containers/systemd/`, `systemctl --user` from a real login
  (ssh), `loginctl enable-linger`, `podman volume ls`.
- `podman build -t`, `podman images`, `podman run -e`.
- `docker.io` on Ubuntu; Docker's own `docker-ce` repository on RHEL
  relatives. `/etc/docker/daemon.json`, `docker info`.
