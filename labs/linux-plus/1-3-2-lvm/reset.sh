findmnt -rn -o SOURCE /mnt/one 2>/dev/null | grep -q vglab && umount -l /mnt/one
vgchange -an vglab >/dev/null 2>&1
vgremove -ff vglab >/dev/null 2>&1
rmdir /mnt/one 2>/dev/null
true
