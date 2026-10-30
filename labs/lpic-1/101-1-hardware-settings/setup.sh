modinfo pcspkr >/dev/null 2>&1 || refuse "this kernel has no pcspkr module, which task 3 needs."
command -v lspci >/dev/null || pkg_install pciutils
state_set boot-id "$(cat /proc/sys/kernel/random/boot_id)"
# Files that already blacklist pcspkr don't count for task 3.
grep -lsE '^[[:space:]]*blacklist[[:space:]]+pcspkr\b' /etc/modprobe.d/*.conf >"$LAB_STATE/old-blacklists" || true
