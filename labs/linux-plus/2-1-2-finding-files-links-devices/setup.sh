for f in /root/findme-*.txt /tmp/t.txt /tmp/h.txt /tmp/s.txt; do
	[ ! -e "$f" ] && [ ! -L "$f" ] || refuse "$f already exists; remove it first"
done
pkg_installed plocate || { pkg_install plocate; state_set plocate 1; }
command -v lsof >/dev/null || { pkg_install lsof; state_set lsof 1; }
# Something large and something set-user-ID to find.
mkdir -p /var/lib/le-report
head -c 60M /dev/zero >/var/lib/le-report/archive.dat
install -m 4755 /usr/bin/true /usr/local/sbin/le-backup-helper
# A process holding /tmp/held.txt open.
systemd-run --quiet --unit=le-lab-held -p StandardOutput=file:/tmp/held.txt /usr/bin/sleep infinity
