rm -rf /tmp/etc.tar /tmp/etc.tar.gz /tmp/t-gzip.tar* /tmp/t-bzip2.tar* /tmp/t-xz.tar* /tmp/j.gz /tmp/ssh.cpio /tmp/restore /tmp/c
if [ -n "$(state_get no-bzip2)" ] && pkg_installed bzip2; then
	if is_rhel; then dnf -y -q remove bzip2 >/dev/null 2>&1; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge bzip2 >/dev/null 2>&1; fi
fi
true
