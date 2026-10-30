rm -rf /srv/reports /srv/project /srv/shared /backup/project
rmdir /backup 2>/dev/null
users_remove
groupdel finance 2>/dev/null
groupdel devs 2>/dev/null
true
