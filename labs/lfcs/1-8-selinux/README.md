# LFCS 1.8: SELinux

Labels for a new web content location, a moved file, a new sshd port, a
boolean, and the boot mode. Keep SELinux enforcing throughout.

## Before you start

RHEL family only. The lab installs `policycoreutils-python-utils` (for
`semanage`) and adds a small service that notes the SELinux mode at every
boot, so task 5 can be checked. No web server is installed.

## Tasks

1. Serve web pages from `/srv/web` with httpd or nginx, as the document
   root of `http://localhost/`. `curl localhost` returns your
   `/srv/web/index.html`, and `ls -Zd /srv/web` shows
   `httpd_sys_content_t`, still after `sudo restorecon -Rv /srv/web`.
2. Create a page `moved.html` in your home directory, `mv` it into
   `/srv/web`, see it fail, and fix it. `curl localhost/moved.html` returns
   the page.
3. Make sshd listen on port 2222 as well as 22. `ssh -p 2222 localhost`
   connects, and `sudo semanage port -l | grep ssh` lists 2222.
4. Allow the web server to make outbound network connections,
   persistently.
5. Make the system boot in permissive mode, reboot, then set it back to
   enforcing for good. `getenforce` shows `Permissive` after the first
   reboot and `Enforcing` after the second.

## Hints

- `semanage fcontext -a -t ... '/srv/web(/.*)?'`, `restorecon -Rv`,
  `matchpathcon`; the web server's document root setting.
- `ls -Z`, `ausearch -m AVC -ts recent`, `restorecon -v`.
- `semanage port -a -t ssh_port_t -p tcp`, a file in
  `/etc/ssh/sshd_config.d/`, `sshd -t`.
- `getsebool`, `setsebool -P`.
- `/etc/selinux/config`, `getenforce`, `setenforce`.
