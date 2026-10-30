# Linux+ 2.6.2: Running containers

Running a rootless web server container, looking inside it, and seeing how
rootless containers map users to the host.

## Before you start

The VM needs internet access to pull images. The lab installs Podman and
creates user `alice` (password `Lab-Pass-1`), with lingering turned on so
her user services run. Do every task as alice: log in as her, or use
`sudo -iu alice` and then `export XDG_RUNTIME_DIR=/run/user/$(id -u)`.
Write answers to files in alice's `~/answers/` directory (make it first).
Docker Hub limits anonymous pulls; if you hit the limit,
`mirror.gcr.io/library/nginx:1.30` is the same image.

## Tasks

1. Run `nginx:1.30` in the background as a container named `web`, with
   host port 8080 forwarded to its port 80 and the variable `TZ` set to
   `UTC`. Check it with `podman ps`, `curl` and its logs. Leave it running.
2. Get a shell inside `web` and look around (`id`, `/etc/os-release`,
   `$TZ`), and look at it with `podman top` and `podman inspect`. Write the
   `NAME` from the container's `/etc/os-release` to `~/answers/2`.
3. Find the nginx main process on the host side and see which user it runs
   as, then look at the user namespace's UID map and `/etc/subuid`. Write
   the host UID that UID 1 inside alice's containers maps to (the start of
   her subordinate range) to `~/answers/3`.

## Hints

- `podman run -d --name -p 8080:80 -e TZ=UTC docker.io/library/nginx:1.30`,
  `curl -sI http://127.0.0.1:8080`, `podman logs`.
- `podman exec -it web sh`, `podman top web`, `podman inspect web --format
  '{{.State.Status}} {{.State.Pid}} {{json .Config.Env}}'`.
- `ps -o user,pid,cmd -p PID`, `podman unshare cat /proc/self/uid_map`,
  `grep alice /etc/subuid`.
- The chapter's step 4 (stop, start, remove) isn't graded: try it when
  you're done.
