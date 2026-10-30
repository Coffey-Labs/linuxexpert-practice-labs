task 1 "Recovered from emergency mode; the system boots normally"
need "fstab's le-missing line no longer stops the boot" '
	! findmnt --fstab -n -o SOURCE,OPTIONS -S LABEL=le-missing ||
	findmnt --fstab -n -o OPTIONS -S LABEL=le-missing | grep -qw nofail'
need "findmnt --verify reports no errors" 'findmnt --verify 2>&1 | grep -Eq "(^| )0 errors|no errors"'
need "the system reached its default target" 'systemctl is-active --quiet "$(systemctl get-default)"'
need "the system isn't in emergency or rescue mode" '! systemctl is-active --quiet emergency.target && ! systemctl is-active --quiet rescue.target'

task 2 "Root password reset from the boot loader (RHEL family)" self
task 3 "Admin user's password reset with init=/bin/bash (Ubuntu)" self

task 4 "ext4 on /dev/loop40p1, damaged and repaired"
need "/dev/loop40p1 has an ext4 filesystem" '[ "$(blkid -s TYPE -o value /dev/loop40p1)" = ext4 ]'
need "it isn't mounted" '! findmnt -S /dev/loop40p1'
need "it holds some files" '[ "$(debugfs -R "ls -p /" /dev/loop40p1 2>/dev/null | grep -cvE "/(\.|\.\.|lost\+found)/")" -gt 0 ]'
need "e2fsck was run on it after it was made" '
	c=$(date -d "$(tune2fs -l /dev/loop40p1 | sed -n "s/^Filesystem created: *//p")" +%s)
	l=$(date -d "$(tune2fs -l /dev/loop40p1 | sed -n "s/^Last checked: *//p")" +%s)
	[ "$l" -gt "$c" ]'
need "e2fsck -fn reports a clean filesystem" 'e2fsck -fn /dev/loop40p1'

task 5 "A missing /mnt/data disk no longer stops the boot"
need "/etc/fstab still mounts /mnt/data" 'findmnt --fstab -n /mnt/data'
need "the /mnt/data entry has the nofail option" 'findmnt --fstab -n -o OPTIONS /mnt/data | grep -qw nofail'
need "/mnt/data is mounted" 'findmnt -n /mnt/data'
