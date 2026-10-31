command -v update-grub >/dev/null || refuse "this lab needs GRUB 2 with update-grub"
[ -f /boot/grub/grub.cfg ] || refuse "/boot/grub/grub.cfg is missing; this lab needs a system that boots with GRUB 2 from /boot/grub"
[ -e /boot/grub.bak ] && refuse "/boot/grub.bak exists; put it back or remove it first"
command -v update-initramfs >/dev/null || refuse "this lab needs initramfs-tools (update-initramfs)"
mkdir -p "$LAB_STATE/default"
cp -a /etc/default/grub "$LAB_STATE/default/"
[ -d /etc/default/grub.d ] && cp -a /etc/default/grub.d "$LAB_STATE/default/"
# Task 4 looks for initramfs images newer than this.
sleep 1
touch "$LAB_STATE/since"
