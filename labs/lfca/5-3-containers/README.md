# LFCA 5.3: Containers

Running nginx in a container, building an image from a Dockerfile, keeping
a database in a named volume, and a container's own process list.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`, and use Podman as root. Answers
go in `/root/lab-answers/<task>`. The VM needs internet access to install
Podman and pull images. Docker Hub limits anonymous pulls; if you hit the
limit, `mirror.gcr.io/library/NAME` is the same image as
`docker.io/library/NAME`. The lab notes whether Podman is installed; reset
removes what the tasks create, and Podman too if the lab didn't find it.
Containers stop at a reboot, so run `le-lab check` before you reboot.

## Tasks

1. Install Podman, run nginx in a container with `-p 8080:80`, and reach
   it with `curl` from the VM. Look at its logs and open a shell in it with
   `exec`. Leave it running.
2. Write a Dockerfile in `~/mysite` for a static page served by nginx,
   build it, tag it `mysite:1.0`, and run it with `-p 8081:80`. Leave it
   running.
3. Run PostgreSQL with a named volume:
   `podman run -d --name db -e POSTGRES_PASSWORD=secret -v dbdata:/var/lib/postgresql docker.io/library/postgres:18`.
   Create a table with `podman exec -it db psql -U postgres`, remove the
   container, start a new one named `db` with the same volume, and check
   the table is still there. Leave the new one running.
4. Run `podman run --rm alpine ps` and see the container's process list
   start at PID 1. Write the command running as PID 1 to
   `/root/lab-answers/4`.

## Hints

- `dnf install podman` / `apt install podman`. Full image names such as
  `docker.io/library/nginx` work everywhere; short names like `nginx`
  depend on the registries configured.
- `podman run -d --name web -p 8080:80 docker.io/library/nginx`,
  `curl localhost:8080`, `podman logs web`, `podman exec -it web sh`.
- `FROM docker.io/library/nginx` and `COPY index.html
  /usr/share/nginx/html/`; `podman build -t mysite:1.0 ~/mysite`,
  `podman images`.
- In psql: `CREATE TABLE notes (id int, text text);`, `\dt`, `\q`.
  `podman rm -f db`, `podman volume ls`. PostgreSQL takes a few seconds to
  start.
- `podman run --rm docker.io/library/alpine ps`.
