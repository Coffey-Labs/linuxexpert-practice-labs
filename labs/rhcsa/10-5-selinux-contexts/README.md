# RHCSA 10.5: SELinux file and process contexts

Web content in a new place, a file moved from `/tmp`, and what `chcon` and
`restorecon` do.

## Before you start

SELinux must be enforcing; keep it that way. The lab installs `httpd`
(serving the default `/var/www/html`) and `policycoreutils-python-utils`
(for `semanage`), and creates `/web/index.html`, a page that isn't labeled
for the web server yet, and `/var/www/html/label.html`.

## Tasks

1. Serve web content from `/web`, with SELinux enforcing, persistently:
   `DocumentRoot /web` plus `<Directory /web>` / `Require all granted` /
   `</Directory>` in a file in `/etc/httpd/conf.d/`. Before the fix,
   `curl http://localhost/` gives a `403` and `ausearch -m AVC -ts recent`
   shows an `httpd` denial for `/web`; after it, `curl` shows the page and
   `restorecon -Rvn /web` lists nothing to change.
2. Create a file `/tmp/page.html`, `mv` it into `/var/www/html`, and fix
   it. Write the type it had right after the move to
   `/root/lab-answers/2`.
3. Change the type of `/var/www/html/label.html` with `chcon`, then run
   `restorecon` on it. Write the type `restorecon` put back to
   `/root/lab-answers/3`.

## Hints

- `httpd -t`, `systemctl restart httpd`; `ls -Zd /web`;
  `semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?'`,
  `restorecon -Rv /web`; `matchpathcon /web`.
- `ls -Z`, `restorecon -v`.
- `chcon -t user_home_t FILE`, `restorecon -v FILE`.
