# RHCSA 10.6: SELinux port labels

Letting httpd and sshd listen on ports SELinux doesn't expect them on.

## Before you start

SELinux must be enforcing; keep it that way. The lab installs and starts
`httpd` on port 80, installs `policycoreutils-python-utils` (for
`semanage`), and adds a second machine, `peer` (`10.99.0.2`), on the lab
network `10.99.0.0/24` (this VM is `10.99.0.1` there), to test from. Get a
shell there with `sudo ip netns exec lepeer bash`. Keep a console or a
second session open while you change sshd.

## Tasks

1. Make httpd listen on port 8888 as well as 80, with SELinux enforcing,
   reachable from other systems: from the peer,
   `curl http://10.99.0.1:8888/` gets an answer. Open the firewall if it's
   running.
2. Move sshd to port 2222, keeping port 22 working until you've tested it:
   add `Port 22` and `Port 2222` in a file in `/etc/ssh/sshd_config.d/`.
   `ssh -p 2222 localhost` works.

## Hints

- `Listen 8888` in a file in `/etc/httpd/conf.d/`; `systemctl restart
  httpd` fails until `semanage port -a -t http_port_t -p tcp 8888`;
  `semanage port -l -C`; `ss -tln`. If `firewall-cmd --state` says
  running: `firewall-cmd --permanent --add-port=8888/tcp`, `--reload`.
- `semanage port -a -t ssh_port_t -p tcp 2222`, `sshd -t`,
  `systemctl restart sshd`.
