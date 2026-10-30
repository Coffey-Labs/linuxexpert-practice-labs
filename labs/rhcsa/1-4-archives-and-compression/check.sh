task 1 "/root/etc-backup.tar.bz2: a bzip2 archive of /etc"
need "/root/etc-backup.tar.bz2 is bzip2 data" 'file -b /root/etc-backup.tar.bz2 | grep -q "^bzip2 compressed"'
need "it holds files under etc/, such as etc/hostname" 'tar -tjf /root/etc-backup.tar.bz2 | grep -qx etc/hostname'
need "it holds all of /etc (etc/passwd too)" 'tar -tjf /root/etc-backup.tar.bz2 | grep -qx etc/passwd'

task 2 "Only etc/hostname extracted into /tmp/restore"
need "/tmp/restore/etc/hostname is the host name" 'cmp -s /tmp/restore/etc/hostname /etc/hostname'
need "nothing else was extracted" '[ "$(find /tmp/restore -mindepth 1 | wc -l)" = 2 ]'

task 3 "/tmp/messages and /tmp/messages.gz"
need "/tmp/messages exists" '[ -s /tmp/messages ]'
need "it's a copy of /var/log/messages" 'cmp -s <(head -n 5 /tmp/messages) <(head -n 5 /var/log/messages) || cmp -s <(head -n 5 /tmp/messages) <(head -n 5 "$(ls -t /var/log/messages-* 2>/dev/null | head -n1)")'
need "/tmp/messages.gz is gzip data" 'gzip -t /tmp/messages.gz'
need "/tmp/messages.gz uncompresses to /tmp/messages" 'cmp -s <(zcat /tmp/messages.gz) /tmp/messages'

task 4 "/root/home.tgz keeps owners, permissions, SELinux contexts and ACLs"
need "/root/home.tgz is gzip data" 'gzip -t /root/home.tgz'
need "it shows each home directory owned by its user" 'tar -tvzf /root/home.tgz | grep -Eq "^d[^ ]* dana/dana .* home/dana/?$" && tar -tvzf /root/home.tgz | grep -Eq "^d[^ ]* erik/erik .* home/erik/?$"'
need "it holds SELinux contexts (--selinux)" 'zcat /root/home.tgz | grep -aq "RHT\.security\.selinux"'
need "it holds ACLs (--acls)" 'zcat /root/home.tgz | grep -aq "SCHILY\.acl\.access"'
