# Linux+ 4.1.4: Kubernetes, Swarm and Compose

A two-service stack with Compose on Podman, and a pod turned into
Kubernetes YAML and played back, all rootless.

## Before you start

The VM needs internet access. The lab installs Podman and creates user
`alice` (password `Lab-Pass-1`), with lingering turned on so her user
services run. Install `podman-compose` yourself (from EPEL on RHEL
relatives). Do the container work as alice: log in as her, or use
`sudo -iu alice` and then `export XDG_RUNTIME_DIR=/run/user/$(id -u)`.
Docker Hub limits anonymous pulls; if you hit the limit, use
`mirror.gcr.io/library/...` instead of `docker.io/library/...`.

## Tasks

1. In `~/stack`, write a `compose.yaml` with two services: `web`
   (`nginx:1.30`, host port 8080 to port 80) and `cache` (`redis:8`). Bring
   it up with `podman-compose`, check it with `ps`, `curl` and the logs,
   and leave it running. (The chapter then runs `podman-compose down`;
   skip that here.)
2. Create a pod `lab` that publishes host port 8081 to port 80, and run
   `nginx:1.30` in it. Generate Kubernetes YAML for it as
   `~/stack/lab.yaml`, remove the pod, and start it again from the YAML
   with `podman kube play`. Leave it running.

## Hints

- `dnf install podman-compose` (EPEL), `apt install podman-compose`;
  `podman-compose up -d`, `podman-compose ps`, `podman-compose logs web`,
  `curl -sI http://127.0.0.1:8080`.
- `podman pod create --name lab -p 8081:80`, `podman run -d --pod lab`,
  `podman kube generate lab > lab.yaml`, `podman pod rm -f lab`,
  `podman kube play lab.yaml`, `podman pod ps`.
