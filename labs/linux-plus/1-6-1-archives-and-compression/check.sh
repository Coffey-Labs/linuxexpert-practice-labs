smallest=$(ls -S /tmp/t-gzip.tar.gz /tmp/t-bzip2.tar.bz2 /tmp/t-xz.tar.xz 2>/dev/null | tail -n1 | sed 's|^/tmp/t-||; s|\..*||')

task 1 "/etc in /tmp/etc.tar.gz; sshd_config restored into /tmp/restore"
need "/tmp/etc.tar.gz is a gzip-compressed tar archive" 'gzip -t /tmp/etc.tar.gz && tar -tzf /tmp/etc.tar.gz >/dev/null'
need "it has etc/ssh/sshd_config" 'tar -tzf /tmp/etc.tar.gz | grep -qx etc/ssh/sshd_config'
need "/tmp/restore/etc/ssh/sshd_config matches /etc/ssh/sshd_config" 'cmp -s /tmp/restore/etc/ssh/sshd_config /etc/ssh/sshd_config'

task 2 "gzip, bzip2 and xz compared on /tmp/etc.tar"
need "/tmp/etc.tar is a tar archive of /etc" 'tar -tf /tmp/etc.tar | grep -qx etc/ssh/sshd_config'
need "/tmp/t-gzip.tar.gz is valid gzip" 'gzip -t /tmp/t-gzip.tar.gz'
need "/tmp/t-bzip2.tar.bz2 is valid bzip2" 'bzip2 -t /tmp/t-bzip2.tar.bz2'
need "/tmp/t-xz.tar.xz is valid xz" 'xz -t /tmp/t-xz.tar.xz'
need "the uncompressed copies are kept (-k)" '[ -f /tmp/t-gzip.tar ] && [ -f /tmp/t-bzip2.tar ] && [ -f /tmp/t-xz.tar ]'
need "/root/lab-answers/2 names the tool with the smallest file${smallest:+, $smallest}" '[ -n "$smallest" ] && [ "$(answer 2)" = "$smallest" ]'

task 3 "The journal in /tmp/j.gz, its error lines counted"
need "/tmp/j.gz is valid gzip" 'gzip -t /tmp/j.gz'
need "it holds lines from the journal" '[ "$(zcat /tmp/j.gz | wc -l)" -ge 50 ]'
need "/root/lab-answers/3 has the count of lines with error" '[ "$(answer 3 | tr -dc 0-9)" = "$(zgrep -c -i error /tmp/j.gz)" ]'

task 4 "ssh in /tmp/ssh.cpio, unpacked in /tmp/c"
need "/tmp/ssh.cpio is a cpio archive with ssh/sshd_config" 'cpio -it </tmp/ssh.cpio 2>/dev/null | grep -qx ssh/sshd_config'
need "/tmp/c/ssh/sshd_config matches /etc/ssh/sshd_config" 'cmp -s /tmp/c/ssh/sshd_config /etc/ssh/sshd_config'
