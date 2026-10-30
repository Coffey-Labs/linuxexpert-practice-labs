id newbie >/dev/null 2>&1 && refuse "user newbie exists already; remove it first (userdel -r newbie)"
user_add alice
h=$(getent passwd alice | cut -d: -f6)
rm -f "$h/bin/hello"
if [ -e /etc/skel/welcome.txt ]; then
	cp -a /etc/skel/welcome.txt "$LAB_STATE/skel-welcome.txt"
	rm -f /etc/skel/welcome.txt
fi
true
