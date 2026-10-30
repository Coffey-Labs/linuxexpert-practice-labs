pkill -KILL -u newbie 2>/dev/null
userdel -r newbie 2>/dev/null
rm -f /etc/skel/welcome.txt
[ -f "$LAB_STATE/skel-welcome.txt" ] && cp -a "$LAB_STATE/skel-welcome.txt" /etc/skel/welcome.txt
rm -rf /tmp/le-mkcd
users_remove
true
