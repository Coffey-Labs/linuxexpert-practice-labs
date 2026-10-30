userdel -r carol 2>/dev/null
userdel -r dave 2>/dev/null
groupdel developers 2>/dev/null
grep -rls webadmins /etc/sudoers.d 2>/dev/null | xargs -r rm -f
rm -f /srv/projects/dave-notes.txt /var/tmp/dave-scratch.tmp
rmdir /srv/projects 2>/dev/null
users_remove
groupdel webadmins 2>/dev/null
true
