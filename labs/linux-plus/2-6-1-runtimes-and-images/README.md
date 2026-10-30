# Linux+ 2.6.1: Container runtimes and images

Pulling and inspecting an image, building one from a Containerfile,
rebuilding with the layer cache, and tagging and pruning, all rootless.

## Before you start

The VM needs internet access to pull images. The lab installs Podman and
creates user `alice` (password `Lab-Pass-1`), with lingering turned on so
her user services run. Do every task as alice: log in as her, or use
`sudo -iu alice` and then `export XDG_RUNTIME_DIR=/run/user/$(id -u)`.

## Tasks

1. Pull `registry.access.redhat.com/ubi10/ubi-minimal`, list your images,
   and show its OS, architecture and default command.
2. In `~/img`, write `app.py` (it prints `hello from` and its arguments)
   and a `Containerfile` based on that image that installs `python3` with
   `microdnf`, copies `app.py` to `/opt/app.py`, runs as user 1001, has
   the entrypoint `python3 /opt/app.py` and the default argument
   `default`. Build it as `hello:1.0`, run it with and without arguments,
   and look at its history.
3. Change `app.py`, rebuild `hello:1.0`, and notice that the package layer
   comes from the cache.
4. Tag `hello:1.0` as `hello:latest`, remove the `latest` tag again, and
   prune the dangling images that rebuilding left behind.

## Hints

- `podman pull`, `podman images`, `podman image inspect --format
  '{{.Os}}/{{.Architecture}} {{.Config.Cmd}}'`.
- `FROM`, `RUN microdnf install -y python3 && microdnf clean all`, `COPY`,
  `USER 1001`, `ENTRYPOINT ["python3", "/opt/app.py"]`, `CMD
  ["default"]`; `podman build -t hello:1.0 .`, `podman run --rm`,
  `podman history`.
- "Using cache" in the build output.
- `podman tag`, `podman rmi`, `podman image prune -f`,
  `podman images -f dangling=true`.
