for f in mkusers bigfiles regular-users updown; do
	[ -e /usr/local/bin/$f ] && refuse "/usr/local/bin/$f already exists; the lab asks you to write it. Remove it and start the lab again."
done
for u in kim lee max; do
	id "$u" >/dev/null 2>&1 && refuse "user $u already exists; task 1 creates it. Remove it (userdel -r $u) and start the lab again."
done
user_add dora
printf 'kim\n\nlee\ndora\n\n\nmax\n' >/root/users.txt
