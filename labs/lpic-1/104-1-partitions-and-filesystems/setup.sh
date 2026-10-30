# Task 5 needs Btrfs. RHEL and Rocky Linux have neither the module nor
# btrfs-progs; AlmaLinux 10, Debian and Ubuntu have both.
command -v mkfs.btrfs >/dev/null || pkg_install btrfs-progs ||
	refuse "there's no btrfs-progs package here (RHEL and Rocky Linux leave Btrfs out), and task 5 needs it; use AlmaLinux or Ubuntu."
modprobe btrfs 2>/dev/null || refuse "this kernel has no Btrfs support, which task 5 needs (RHEL and Rocky Linux leave it out; use AlmaLinux or Ubuntu)."
disk_add 0 4G >/dev/null
disk_add 1 4G >/dev/null
