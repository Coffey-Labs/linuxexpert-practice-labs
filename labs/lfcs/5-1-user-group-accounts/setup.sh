groupadd -f webadmins
user_add wendy -G webadmins
user_add dave
# Files dave owns outside his home directory; task 5 finds them.
mkdir -p /srv/projects
echo "dave's notes" >/srv/projects/dave-notes.txt
echo scratch >/var/tmp/dave-scratch.tmp
chown dave: /srv/projects/dave-notes.txt /var/tmp/dave-scratch.tmp
state_set dave-uid "$(id -u dave)"
