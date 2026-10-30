rm -f /etc/nologin
systemctl unmask legacy-echo.service 2>/dev/null
systemctl disable --now --quiet legacy-echo.service 2>/dev/null
rm -f /usr/local/lib/systemd/system/legacy-echo.service /etc/systemd/system/legacy-echo.service /usr/local/lib/le-lab/legacy-echo.py
rmdir /usr/local/lib/systemd/system /usr/local/lib/systemd 2>/dev/null
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
rm -rf /root/lab-keys
users_remove
true
