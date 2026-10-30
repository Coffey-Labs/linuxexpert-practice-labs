command -v bzip2 >/dev/null || pkg_install bzip2
command -v xz >/dev/null || pkg_install xz/xz-utils
dev=$(disk_add 0 64M)
parted -s "$dev" mklabel msdos mkpart primary 1MiB 100%
printf 'LINUXexpert practice disk: you found the text.' | dd of="$dev" bs=512 seek=40 conv=notrunc status=none
sync
