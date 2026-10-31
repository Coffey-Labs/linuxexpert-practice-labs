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
- `nodes_up N`, `in_node NAME CMD`: managed nodes `node1`..`nodeN` for
  Ansible labs (see "Managed nodes" below)
- `hosts_add LINE`: an `/etc/hosts` line reset takes out again
- `state_set KEY VALUE`, `state_get KEY`: notes for check and reset
- `sshd_restart`: restart sshd after reset puts its settings back, and
  check port 22 answers (on Ubuntu, never restart `ssh.service` yourself)

The peer shares the VM's files, users and `/etc`, but has its own
addresses, routes, firewall and ports. It has no route beyond the VM, so
DNS lookups made there time out: give peer services addresses, not names,
and bind them to `10.99.0.2` (which resolves from `/etc/hosts`), for
example `python3 -m http.server 8080 --bind 10.99.0.2`. A service that
should run in the peer gets `NetworkNamespacePath=/run/netns/lepeer` and
`After=le-lab-peer.service` in its unit; the peer comes back at every
boot.

### Managed nodes

Where a guide has a control node and managed nodes (EX294), the VM is the
control node and `nodes_up N` (1 to 9) in setup.sh adds `node1`..`nodeN`:
podman containers from AlmaLinux 10 (`quay.io/almalinuxorg/10-init`, no
login needed), at `10.99.1.11`, `.12`, ... with names in `/etc/hosts`.
Each has systemd as PID 1, its own files, packages, users, services and
cron, and sshd on port 22. `root` and `ansible` (in `wheel`, so sudo asks
for the password) have password `Lab-Pass-1`, and root may log in with it.
dnf uses the real AlmaLinux repositories; the node image starts with a
copy of the VM's dnf metadata, so the first `dnf` in a node is quick.
The image is about 200 MB to pull (seconds from quay.io) and 300 MB
built; `nodes_up` takes about 20 seconds once podman is installed. In the
nodes, dnf moves on from a mirror slower than 100 kB/s after 15 seconds.
Tested on the RHEL family; EX294 labs are `SYSTEMS="rhel"`.

- `in_node NAME CMD...` runs a command as root in a node (one argument
  runs as shell code); `in_node -i NAME 'cat >FILE' <<EOF` passes standard
  input. Use it in check.sh to grade a node: `need "devops exists on node1"
  'in_node node1 id devops'`.
- `nodes_names` lists the nodes, `node_addr NAME` prints an address,
  `nodes_wait` waits until every node's sshd answers (check.sh can start
  with `nodes_wait 60 || true`).
- For a root shell on a node, students use `sudo podman exec -it node1 bash`.
- Reset calls `nodes_down` for you: it removes the containers, their
  network, `le-lab-nodes.service`, the images setup pulled or built, the
  `/etc/hosts` lines, and podman itself (with all its containers and
  images) if `nodes_up` installed it.

The containers are kept, not recreated, so whatever a student does in a
node survives a reboot of the VM: `le-lab-nodes.service` starts them again
at boot and waits for their sshd before `multi-user.target`.
`systemctl reboot` inside a node restarts just that container, also with
its state kept.

What works in a node: packages (`dnf`), users, groups, passwords and
sudo, files and templates, services and targets (`systemctl enable`,
`mask`, `set-default`), cron, the journal, and firewalld once it's
installed (each node has its own network stack, so a node's firewall
really blocks the control node). The image has only sshd, sudo, Python,
cron and a few tools; a lab installs anything else it needs with
`in_node NAME dnf -y -q install ...`.

What doesn't, because the nodes share the VM's kernel:

- **SELinux** is off inside a node, so `sefcontext`, `seboolean`,
  `selinux` and `restorecon` tasks have nothing to act on.
- **Storage**: a node has no block devices and may not mount; partitions,
  LVM, file systems and fstab mounts fail there.
- **Time**: `chronyd` is skipped (no permission to set the clock), so it
  can be enabled but never active.
- **Rebooting**: the boot ID and uptime are the VM's, so Ansible's
  `reboot` module waits in vain; reboot the VM instead.
- **Host names**: `hostnamectl` and `hostname` are refused (podman sets
  each node's name), and kernel settings (sysctl, boot loader, kernel
  modules) belong to the VM.

Tasks of those kinds target the control node itself: put `localhost
ansible_connection=local` in the inventory (a group such as `[storage]`),
give the VM spare disks with `disk_add`, and grade the VM as usual.

**setup.sh** makes the starting point. Every graded task must fail right
after setup: if a fresh system already passes a task, set up the opposite.
Install what the scenario needs, but never what a task asks the student to
install. If the VM doesn't meet a precondition, stop with `refuse MESSAGE`
before changing anything: the lab isn't marked as started, so the student
can fix it and run `start` again.

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

Give servers time to start: a check that grades a port the student opened
should poll for a few seconds (up to about 15) before failing. `python3 -m
http.server` in particular looks up its bind address in DNS before it
listens, which can take over 10 seconds unless the address is in
`/etc/hosts`; for lab-made web servers, use a small script on
`http.server.ThreadingHTTPServer` with `server_bind` kept to the plain
socket bind instead.

Mark a task `self` only when it can't be checked from the running system,
such as a boot-loader recovery. Say in its README text how to check it.

Logs need care. AlmaLinux keeps the journal only in memory until someone
makes it persistent, so a message from before a reboot is gone after it;
read `/var/log/messages` or `/var/log/secure` as well, or mark the lab
`noreboot`. rsyslog writes `logger` messages to those files a moment
later, so a check that runs right away can miss them: poll briefly.

**reset.sh** undoes the scenario and the usual results of the tasks (the
users, files, units and settings they create), so that `le-lab start` on the
same lab scores 0% again. That includes packages a task installs: note in
setup which ones were missing, and remove them again in reset. Lab users,
spare disks and the peer are removed for you after `reset.sh` runs. Don't
fail on things that aren't there.

## Rules

- Tasks come from the chapter's "Try it" section. Never use exam
  questions or tasks from anywhere else.
- Labs run on one VM. Where the guide says "the other VM", use the peer;
  where it says "a spare disk", use `disk_add`.
- Never touch the interface or address the student is connected over, the
  root filesystem, or the boot loader, unless the task is about exactly
  that.
- Plain words, US spelling, no product names the guide doesn't use.
