systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
groupdel sales 2>/dev/null
groupdel market 2>/dev/null
users_remove
while read -r g; do groupdel "$g" 2>/dev/null; done <"$LAB_STATE/groups" 2>/dev/null
true
