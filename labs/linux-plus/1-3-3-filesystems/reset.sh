for m in /mnt/e /mnt/x; do
	findmnt -rn -o SOURCE "$m" 2>/dev/null | grep -q loop4 && umount -l "$m"
	rmdir "$m" 2>/dev/null
done
true
