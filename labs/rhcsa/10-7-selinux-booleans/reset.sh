systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
setsebool -P httpd_can_network_connect=off httpd_enable_homedirs=off 2>/dev/null
true
