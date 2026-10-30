# Linux+ 2.4.4: Web and mail services

A name-based site with Nginx on Ubuntu, an Apache virtual host with the
right SELinux label on RHEL relatives, and local mail with Postfix.

## Before you start

The VM needs internet access to install packages. The lab only checks that
`/srv/www` doesn't exist yet, and notes the time, so that only mail sent
from now on counts. Leave your work in place for grading: `le-lab reset`
removes the packages it finds you installed.

## Tasks

1. Debian and Ubuntu: install Nginx and serve `/srv/www/lab` (with an
   `index.html` of your own) for the name `lab.test` on port 80, from a file
   in `/etc/nginx/conf.d/`. `curl -s -H 'Host: lab.test' http://127.0.0.1/`
   returns your page. Break the syntax on purpose once, and read what
   `nginx -t` says before you fix it.
2. RHEL relatives: install Apache and serve `/srv/www/shop` (with an
   `index.html` of your own) as the virtual host `shop.test` on port 80,
   starting at boot. Keep SELinux enforcing: give `/srv/www` the right
   label with a rule that survives a relabel.
   `curl -s -H 'Host: shop.test' http://127.0.0.1/` returns your page.
3. Install Postfix and a `mail` command, make sure Postfix is running, and
   send yourself a local mail with the subject `test`. Read it with `mail`.

## Hints

- `apt install nginx`, a `server {}` block with `listen`, `server_name`
  and `root`; `nginx -t`, `systemctl reload nginx`.
- `dnf install httpd`, a `<VirtualHost *:80>` block in
  `/etc/httpd/conf.d/`, `apachectl configtest`; a 403 means the label is
  wrong. `semanage fcontext -a -t httpd_sys_content_t '/srv/www(/.*)?'`
  (package `policycoreutils-python-utils`), `restorecon -Rv /srv/www`.
- `postfix` with `s-nail` (RHEL relatives) or `mailutils` (Ubuntu,
  "Local only"); `systemctl enable --now postfix`; `echo hi | mail -s test
  $USER`.
