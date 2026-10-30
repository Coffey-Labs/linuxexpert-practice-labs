# Linux+ 2.6.3: Container storage and networks

A bind mount that SELinux allows, a named volume that outlives its
containers, and name resolution on a user-defined network, all rootless.

## Before you start

The VM needs internet access to pull images. The lab installs Podman and
creates user `alice` (password `Lab-Pass-1`), with lingering turned on so
her user services run. Do every task as alice: log in as her, or use
`sudo -iu alice` and then `export XDG_RUNTIME_DIR=/run/user/$(id -u)`.
Docker Hub limits anonymous pulls; if you hit the limit, use
`mirror.gcr.io/library/...` instead of `docker.io/library/...`. Leave the
containers, the volume and the network in place for grading.

## Tasks

1. Put an `index.html` in `~/site`, and run `nginx:1.30` as a container
   named `site` on host port 8080 that serves `~/site` read-only from
   `/usr/share/nginx/html`. On RHEL relatives, keep SELinux enforcing: run
   it once without a label option and see the 403, then fix it.
2. Create the volume `labdata`. Write the date to `first.txt` in it from
   one `alpine:3.24` container, and read it back from another.
3. Create the network `labnet` and run `nginx:1.30` on it as a container
   named `back`. From another container on `labnet`, fetch
   `http://back` by name.

## Hints

- `podman run -d --name site -p 8080:80 -v ~/site:/usr/share/nginx/html:ro`,
  then `:ro,Z`; `curl -s http://127.0.0.1:8080`, `ls -Zd ~/site`.
- `podman volume create`, `podman run --rm -v labdata:/data
  docker.io/library/alpine:3.24 sh -c 'date > /data/first.txt'`.
- `podman network create`, `podman run --network labnet`, `wget -qO-
  http://back` from an alpine container.
