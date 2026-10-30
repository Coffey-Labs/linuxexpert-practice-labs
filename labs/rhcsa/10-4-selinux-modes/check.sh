LOG=$LAB_STATE/watch.log
# The first line of each boot: the mode that boot started in.
boot_modes() { awk '!s[$1]++' "$LOG" 2>/dev/null; }
now_enforcing() {
	need "/etc/selinux/config sets SELINUX=enforcing" 'grep -Eq "^[[:space:]]*SELINUX=enforcing[[:space:]]*$" /etc/selinux/config'
	need "getenforce prints Enforcing now" '[ "$(getenforce)" = Enforcing ]'
	need "the kernel command line doesn't override it" '! grep -Eq "(^| )(enforcing=0|selinux=0)( |$)" /proc/cmdline'
}

task 1 "Permissive until the next reboot, enforcing at boot"
need "SELinux was permissive while the config said enforcing" 'grep -q " Permissive SELINUX=enforcing$" "$LOG"'
now_enforcing

task 2 "Booted in permissive mode once, then enforcing again"
need "a boot since the lab started ran in permissive mode from the config" 'boot_modes | grep -q " Permissive SELINUX=permissive$"'
now_enforcing
