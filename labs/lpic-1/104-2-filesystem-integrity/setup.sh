command -v mkfs.xfs >/dev/null || pkg_install xfsprogs
disk_add 0 100M >/dev/null
disk_add 1 512M >/dev/null
