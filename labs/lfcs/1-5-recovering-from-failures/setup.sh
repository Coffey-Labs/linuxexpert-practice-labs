# Emergency mode needs root's password; without one the student is stuck.
case $(passwd -S root 2>/dev/null | awk '{print $2}') in
L* | NP)
	refuse "root has no usable password, and this lab's next boot stops in emergency mode, which asks for it. Run: sudo passwd root, then start the lab again."
	;;
esac

cp -a /etc/fstab "$LAB_STATE/fstab.orig"

# Task 4: an empty partition on spare disk 0.
d0=$(disk_add 0 1G)
parted -s "$d0" mklabel gpt mkpart data 1MiB 100%
udevadm settle
[ -b "${d0}p1" ] || partx -u "$d0"

# Task 5: a filesystem on spare disk 1, mounted from fstab without nofail.
d1=$(disk_add 1 512M)
mkfs.ext4 -q -L le-data "$d1"
uuid=$(blkid -s UUID -o value "$d1")
state_set data-uuid "$uuid"
mkdir -p /mnt/data /mnt/missing
printf 'UUID=%s /mnt/data ext4 defaults 0 2\n' "$uuid" >>/etc/fstab

# Task 1: a line for a device that doesn't exist.
printf 'LABEL=le-missing /mnt/missing ext4 defaults 0 2\n' >>/etc/fstab
systemctl daemon-reload
mount /mnt/data
echo "Lab data" >/mnt/data/README
