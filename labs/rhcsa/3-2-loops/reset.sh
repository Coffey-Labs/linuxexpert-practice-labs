rm -f /usr/local/bin/mkusers /usr/local/bin/bigfiles /usr/local/bin/regular-users /usr/local/bin/updown
for u in kim lee max; do
	pkill -KILL -u "$u" 2>/dev/null
	userdel -r "$u" 2>/dev/null
done
rm -f /root/users.txt
true
