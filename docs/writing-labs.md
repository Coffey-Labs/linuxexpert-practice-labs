# Writing a lab

A lab is one study guide chapter's "Try it" section turned into a scenario
that `le-lab` can set up, grade and undo. Copy
`labs/lfcs/5-1-user-group-accounts/` as a starting point.

## Files

```
labs/<guide>/<chapter-slug>/
  lab.conf     title, chapter link, supported systems
  README.md    what the lab is, what it sets up, the numbered tasks
  setup.sh     prepares the scenario
  check.sh     grades it
  reset.sh     undoes it
```

The folder name is the chapter's file name, so `lfcs/2-4-openssh` is the lab
for `/lfcs/2-networking/2-4-openssh/`.

`lab.conf` is shell variables:

```sh
TITLE="2.4 OpenSSH"
CHAPTER=/lfcs/2-networking/2-4-openssh/
SYSTEMS="rhel debian"     # or just one of them
```

`README.md` has a short intro, `## Before you start` (what setup made:
users, disks, the peer), `## Tasks` as a numbered list, and `## Hints`.
`le-lab tasks` prints the Tasks section, so keep it readable as plain text.
Task numbers in the README and in `check.sh` must match.

## The scripts

All three run as root, with `lib/lab.sh` already sourced. `setup.sh` runs
with `set -e`. Read `lib/lab.sh` for the helpers; the ones most labs use:

- `is_rhel`, `is_debian`, `pick RHEL-VALUE DEBIAN-VALUE`
- `pkg_install name` or `pkg_install rhel-name/debian-name`
- `user_add NAME [useradd options]`: a lab user with password `Lab-Pass-1`,
  removed again by reset
- `disk_add N SIZE`: spare disk N as `/dev/loop4N`, attached again at every
  boot; reset removes it and anything on it
- `peer_up`, `in_peer CMD`: a second machine as a network namespace, at
  `10.99.0.2` (name `peer`), linked to the VM's `10.99.0.1`
- `hosts_add LINE`: an `/etc/hosts` line reset takes out again
- `state_set KEY VALUE`, `state_get KEY`: notes for check and reset

The peer shares the VM's files, users and `/etc`, but has its own
addresses, routes, firewall and ports. It has no route beyond the VM, so
DNS lookups made there time out: give peer services addresses, not names,
and bind them to `10.99.0.2` (which resolves from `/etc/hosts`), for
example `python3 -m http.server 8080 --bind 10.99.0.2`. A service that
should run in the peer gets `NetworkNamespacePath=/run/netns/lepeer` and
`After=le-lab-peer.service` in its unit; the peer comes back at every
boot.

**setup.sh** makes the starting point. Every graded task must fail right
after setup: if a fresh system already passes a task, set up the opposite.
Install what the scenario needs, but never what a task asks the student to
install.

**check.sh** lists the tasks and what must be true for each:

```sh
task 1 "Key-only logins, no root, only group sshusers"
need "sshd allows no password logins" 'sshd -T | grep -qx "passwordauthentication no"'
need "sshd is running" active sshd

task 2 "Make sshd listen on 2222 too" rhel     # graded on RHEL relatives only
task 3 "Reset root's password from the boot loader" self   # not graded
```

A check in one quoted string runs as shell code, so it can use pipes, `!`
and `$(...)`. The first failing `need` is shown to the student, so word it
as what should be true. Check results, not methods: any correct approach
must pass. Where a task asks for a finding ("which process..."), have the
student write it to `/root/lab-answers/<task>` and compare it with `answer
N` or `grep`.

Tasks that say "after a reboot" are graded on what makes them persistent
(the config file, the enabled unit) and on the live state.

Mark a task `self` only when it can't be checked from the running system,
such as a boot-loader recovery. Say in its README text how to check it.

**reset.sh** undoes the scenario and the usual results of the tasks (the
users, files, units and settings they create), so that `le-lab start` on the
same lab scores 0% again. Lab users, spare disks and the peer are removed
for you after `reset.sh` runs. Don't fail on things that aren't there.

## Rules

- Tasks come from the chapter's "Try it" section. Never use exam
  questions or tasks from anywhere else.
- Labs run on one VM. Where the guide says "the other VM", use the peer;
  where it says "a spare disk", use `disk_add`.
- Never touch the interface or address the student is connected over, the
  root filesystem, or the boot loader, unless the task is about exactly
  that.
- Plain words, US spelling, no product names the guide doesn't use.
