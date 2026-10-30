# Linux+ 3.3.3: SELinux

The classic moved-file problem with a web server, reading the denial, and a
boolean. Keep SELinux enforcing throughout.

## Before you start

RHEL family only. SELinux must be enforcing. The web server isn't
installed or started by the lab: that's task 1. The lab sets the boolean
`httpd_enable_homedirs` off. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Look around (`sestatus`, `ls -Zd`, `ps -eZ`, `getsebool -a`). Install
   `httpd`, and enable and start it.
2. As your normal user, create `~/moved.html` with the text `moved`, and
   `sudo mv` it into `/var/www/html/`. `curl
   http://127.0.0.1/moved.html` returns 403. Read the denial, fix the
   file's label, and see the page served. Then try `chcon -t user_home_t`
   on it and see `restorecon` undo that too.
3. Write the SELinux type the moved file had before you fixed it to
   `/root/lab-answers/3`.
4. Turn the boolean `httpd_enable_homedirs` on, persistently. (The
   chapter turns it off again afterward; leave it on until you've checked.)

## Hints

- `dnf install httpd`, `systemctl enable --now`.
- `ls -Z`, `ausearch -m AVC -ts recent`; `sealert -a
  /var/log/audit/audit.log` needs the `setroubleshoot-server` package;
  `restorecon -v`.
- The type is the third field of the label.
- `setsebool -P`, `getsebool`.
