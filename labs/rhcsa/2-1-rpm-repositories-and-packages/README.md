# RHCSA 2.1: RPM repositories and packages

A repository with a wrong URL, serving and using a repository of your own,
finding the package that provides a command, and undoing a removal from
dnf's history.

## Before you start

The lab has added a repository `extras-mirror` in
`/etc/yum.repos.d/extras-mirror.repo` that points at a wrong URL, so
`dnf install` fails until you deal with it in task 1. It installs
`createrepo_c`, and removes `policycoreutils-python-utils` if it's
installed.

The peer, at `10.99.0.2` (name `peer`), stands in for the second VM. It
shares this VM's files, so download the packages here (the peer has no
route to the internet) and serve them from the peer. Get a shell there
with `sudo ip netns exec lepeer bash`.

## Tasks

1. See what the wrong URL of `extras-mirror` does to `dnf install`, then
   disable that repository without deleting its file.
2. On the peer, serve a copy of a few packages over HTTP: download them
   with `dnf download` into `/srv/repo`, run `createrepo_c` on the
   directory, and start `python3 -m http.server` there, bound to
   `10.99.0.2`. On this VM, configure that repository as `lab` in
   `/etc/yum.repos.d/lab.repo` with signature checking on, and install one
   of its packages from it.
3. Find and install the package that provides the `semanage` command.
4. Remove a package you installed, then undo the removal from dnf's
   history.

## Hints

- `dnf repolist --all`; `dnf config-manager --set-disabled`, or
  `enabled=0`.
- Pick packages that aren't installed yet, such as `tree`. In the peer:
  `createrepo_c /srv/repo`, then
  `python3 -m http.server 8000 --bind 10.99.0.2 --directory /srv/repo &`.
  The repo file needs `baseurl=http://10.99.0.2:8000/`, `gpgcheck=1` and
  a `gpgkey=` from `/etc/pki/rpm-gpg/`. `dnf repoinfo lab`;
  `dnf install --repo lab NAME` takes it from that repository only.
- `dnf provides semanage` (or `'*/semanage'`).
- `dnf history list`, `dnf history info`, `dnf history undo`.
