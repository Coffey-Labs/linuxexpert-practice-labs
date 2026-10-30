umount /mnt/lab 2>/dev/null
cryptsetup close lab 2>/dev/null
rmdir /mnt/lab 2>/dev/null
rm -f /root/lab.key /root/n.txt /root/n.txt.gpg /home/*/n.txt /home/*/n.txt.gpg
true
