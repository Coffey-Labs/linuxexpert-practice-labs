rm -rf /tmp/etc.tar /tmp/etc.tar.gz /tmp/t-gzip.tar* /tmp/t-bzip2.tar* /tmp/t-xz.tar* /tmp/j.gz /tmp/ssh.cpio /tmp/restore /tmp/c
# Task 2 has the student install bzip2 if it's missing; reset removes it.
pkg_installed bzip2 || state_set no-bzip2 1
true
