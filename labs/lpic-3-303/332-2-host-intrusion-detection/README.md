# LPIC-3 332.2: Host intrusion detection

Audit rules and searches, package verification, AIDE with a scheduled
check, OpenSCAP, and rootkit scanners.

## Before you start

The lab has changed one configuration file that belongs to one of the
packages `logrotate`, `sudo`, or the OpenSSH client (`openssh-clients` on
the RHEL family, `openssh-client` on Ubuntu), for you to find in task 2.
Write answers to the files in `/root/lab-answers/`.

Do task 1's test as your own login user (not root), from your SSH or
console session, so that the audit system knows who you are.

## Tasks

1. Install the audit tools if they're missing (`audit-rules` on the RHEL
   family, `auditd` on Ubuntu). Add two audit rules, permanently, with a
   file in `/etc/audit/rules.d/` and `augenrules`: a watch on `/etc/hosts`
   for writes and attribute changes with the key `hosts-change`, and a
   rule, key `access-denied`, for `openat` calls that fail with `EACCES` by
   users with a login UID of 1000 or more. Then change `/etc/hosts` (and
   put it back), try to read `/etc/shadow` as your login user, and find
   both events with `ausearch`.
2. Find the changed file with your package manager's verify function, and
   write its full path to `/root/lab-answers/2`.
3. Install AIDE and write your own configuration, `/root/aide/lab.conf`,
   that reads the database from `/root/aide/aide.db`, writes new ones to
   `/root/aide/aide.db.new`, uncompressed, and covers `/etc/ssh` and
   `/usr/sbin` with permissions, owner, group, size, mtime and SHA-256.
   Build the database as `/root/aide/aide.db`. Plant a file in
   `/usr/sbin`, change a file in `/etc/ssh`, see AIDE report both, and put
   things back.
4. Schedule that check nightly at 3:30 with a file in `/etc/cron.d`,
   mailing its output to root.
5. RHEL family: evaluate the CIS Level 1 server profile's rules
   `package_aide_installed` and `sshd_disable_root_login` with `oscap`,
   saving the results to `/root/oscap-results.xml`.
6. Ubuntu: install `chkrootkit`, `rkhunter` and `debsums`, record
   rkhunter's baseline of file properties, and run both scanners.

## Hints

- `auditctl -w PATH -p wa -k KEY`; `-a always,exit -F arch=b64 -S openat
  -F exit=-EACCES -F 'auid>=1000' -F auid!=unset -k KEY`; `augenrules
  --load`, `auditctl -l`; `ausearch -k KEY -i`, `-f FILE`, `aureport -k
  --summary`.
- `rpm -Va` or `rpm -V PACKAGE`; `dpkg --verify`, `debsums -as`.
- `database_in=file:...`, `database_out=file:...`, `gzip_dbout=no`, a
  rule line such as `LabRule = p+u+g+s+m+sha256`, then `/etc/ssh LabRule`;
  `aide --init -c FILE`, `aide --check -c FILE`.
- `MAILTO=root`, then `minute hour day month weekday user command`.
- `/usr/share/xml/scap/ssg/content/` (pick the data stream for your
  distribution); `oscap info --profiles`; `oscap xccdf eval --profile ...
  --rule xccdf_org.ssgproject.content_rule_NAME --results FILE`.
- `apt-get install --no-install-recommends`; `rkhunter --propupd`,
  `rkhunter --check --sk`, `chkrootkit -q`; `/var/log/rkhunter.log`.
