# LPIC-3 333.2: Mandatory access control

SELinux on a web server: a non-standard port and directory, the trouble
with `mv`, a boolean, a permissive domain, a policy module, and a confined
user.

## Before you start

SELinux must be enforcing. The lab creates the user `confined` (password
`Lab-Pass-1`) for task 5. Work as root; keep the policy module files of
task 4 in `/root/selinux`.

## Tasks

1. Install Apache (`httpd`), `policycoreutils-python-utils` and
   `setools-console`. Make Apache serve `/srv/web` on port 8089, with an
   `index.html` that says `hello from /srv/web`, starting at boot, with
   SELinux enforcing. Fix each denial the narrow way: label the one port,
   and add a file-context rule for `/srv/web` that survives `restorecon`.
2. Create a page `moved.html` that says `moved page` in your home
   directory and `mv` it into `/srv/web`. See it fail and why, then fix
   its label so that Apache serves it.
3. Put a CGI script `/var/www/cgi-bin/lab.sh` that prints `CGI running as`
   and its SELinux context (`id -Z`), and make it work at
   `http://127.0.0.1/cgi-bin/lab.sh`. Turn the `httpd_enable_cgi` boolean
   off for a moment and see it fail, then leave it on.
4. Make `/srv/web/secret.txt` with the type `admin_home_t` and see that
   Apache can't read it. Make `httpd_t` a permissive domain, fetch it
   again, and build a policy module `labweb` from the logged denials with
   `audit2allow` in `/root/selinux`. Install it, fetch the file, then
   remove the module and the permissive domain again, so that the file is
   refused once more.
5. Map `confined` to the SELinux user `user_u`, and log in as `confined`
   (with a key, over SSH) to see the context the session gets.

## Hints

- `sestatus`, `id -Z`, `ls -Z`, `ps -eZ`; `ausearch -m AVC -ts recent`,
  `audit2why`. `semanage port -a -t http_port_t -p tcp 8089`;
  `semanage fcontext -a -t httpd_sys_content_t "/srv/web(/.*)?"`,
  `restorecon -Rv`, `matchpathcon`, `semanage fcontext -l -C`.
- `restorecon -v FILE`; `curl -s -o /dev/null -w '%{http_code}\n' URL`.
- `getsebool`, `setsebool` (with `-P` it lasts), `semanage boolean -l`.
- `chcon -t admin_home_t`; `semanage permissive -a httpd_t` and `-d`;
  `ausearch -m AVC -ts recent -f secret.txt | audit2allow -M labweb`;
  `semodule -i labweb.pp`, `semodule -l`, `semodule -r labweb`.
- `semanage login -a -s user_u confined`, `semanage login -l`;
  `ssh-keygen`, the user's `~/.ssh/authorized_keys`, `restorecon -R`.
