# EX294 9.7: Security

Serve a web page from an unusual directory and port with SELinux
enforcing, using the SELinux modules: a file context rule and a relabel, a
boolean and a port label.

## Before you start

SELinux doesn't work inside the lab's managed-node containers, so this
VM, the control node, is also the web server: `localhost
ansible_connection=local`, in the inventory group `webservers`. The lab
creates the user `greg` (password `Lab-Pass-1`, sudo without a password)
and installs `ansible-core` and `policycoreutils-python-utils` (for
`semanage`). Work as greg, in `/home/greg/ansible`: its `ansible.cfg`
reads the inventory `inventory` and becomes root. The `ansible.posix` and
`community.general` collections aren't installed yet, and neither is
Apache. SELinux is enforcing; keep it that way.

## Tasks

1. Serve a page from `/srv/www` on the web servers: install Apache, put
   an `index.html` in `/srv/www`, add a file context rule and relabel, and
   configure Apache to use `/srv/www` as its document root. Open the
   firewall for HTTP if it's running. `ls -Z /srv/www/index.html` shows
   `httpd_sys_content_t` and `curl http://localhost/` gets the page.
2. Turn on `httpd_can_network_connect` persistently. `getsebool` shows
   `on`, also after a reboot.
3. Label port 8888/tcp as `http_port_t` and make Apache listen on it too,
   with the firewall open for it if it's running. `ss -tlnp | grep 8888`
   shows httpd, and the AVC log (`ausearch -m avc -ts recent`) is quiet.

## Hints

- `ansible-galaxy collection install ansible.posix
  'community.general:>=11,<12'`: community.general 12 and later need a
  newer ansible-core than this one.
- `community.general.sefcontext` with `target: '/srv/www(/.*)?'`, and a
  handler running `restorecon -Rv /srv/www`.
- A file in `/etc/httpd/conf.d/` can set `DocumentRoot /srv/www`, a
  `<Directory /srv/www>` with `Require all granted`, and `Listen 8888`.
- `ansible.posix.seboolean` with `persistent: true`;
  `community.general.seport`.
- `ansible.posix.firewalld`, only where `firewalld.service` is running
  (`service_facts`).
