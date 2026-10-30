fstab_src() { awk -v m="$1" '!/^[[:space:]]*#/ && $2 == m {print $1}' /etc/fstab | tr -d '"' | head -n1; }
fstab_opts() { awk -v m="$1" '!/^[[:space:]]*#/ && $2 == m {print $4}' /etc/fstab | head -n1; }
stick_src_ok() {
	case $(fstab_src /mnt/stick) in
	/dev/loop41 | "UUID=$(blkid -s UUID -o value /dev/loop41)" | LABEL=stick) return 0 ;;
	esac
	return 1
}
# uma can mount and unmount it (left as it was found).
uma_mounts() {
	if findmnt -n /mnt/stick >/dev/null; then
		runuser -u uma -- umount /mnt/stick && runuser -u uma -- mount /mnt/stick
	else
		runuser -u uma -- mount /mnt/stick && runuser -u uma -- umount /mnt/stick
	fi
}
has_file() { [ "$(debugfs -R "ls -p /" /dev/loop40p1 2>/dev/null | grep '^/' | grep -cvE "/(\.|\.\.|lost\+found)/")" -gt 0 ]; }

task 1 "/dev/loop40p1 mounted by hand, a file created on it"
need "the filesystem holds a file of yours" has_file

task 2 "/mnt/data mounted at boot by UUID"
need "/etc/fstab mounts /mnt/data by its UUID" '[ "$(fstab_src /mnt/data)" = "UUID=$(blkid -s UUID -o value /dev/loop40p1)" ]'
need "findmnt --verify reports no errors" 'findmnt --verify 2>&1 | grep -Eq "(^| )0 errors|no errors"'
need "/mnt/data is mounted from /dev/loop40p1" '[ "$(findmnt -n -o SOURCE /mnt/data)" = /dev/loop40p1 ]'

task 3 "The mount unit for /mnt/data"
need "/root/lab-answers/3 names the mount unit" '[ "$(answer 3)" = mnt-data.mount ]'

task 4 "A noauto,users line for the stick, mounted by uma"
need "/etc/fstab has a line for /dev/loop41 at /mnt/stick" stick_src_ok
need "its options include noauto and users" 'o=",$(fstab_opts /mnt/stick),"; case $o in *,noauto,*) ;; *) exit 1 ;; esac; case $o in *,users,* | *,user,*) ;; *) exit 1 ;; esac'
need "uma can mount and unmount /mnt/stick" uma_mounts

task 5 "Remounted read-only and back" self
