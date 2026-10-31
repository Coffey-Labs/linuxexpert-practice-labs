# The nodes go with nodes_down, greg (with his project) with users_remove,
# and the spare disks (with their volume groups) with disks_remove. Here:
# the mounts, then what the tasks and setup installed on this VM.
rm -f /etc/sudoers.d/le-lab-greg
for m in /srv/web /mnt/data /srv/archive; do
	umount -l "$m" 2>/dev/null
	awk -v m="$m" '$1 !~ /^#/ && $2 == m' /etc/fstab | grep -q . &&
		awk -v m="$m" '$1 ~ /^#/ || $2 != m' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
	rm -f /etc/fstab.le-lab
	rmdir "$m" 2>/dev/null
done
systemctl daemon-reload
if [ -f "$LAB_STATE/rpms" ]; then
	new=$(comm -13 "$LAB_STATE/rpms" <(rpm -qa --qf '%{NAME}\n' | sort -u))
	[ -z "$new" ] || dnf -y -q remove $new >/dev/null 2>&1
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
