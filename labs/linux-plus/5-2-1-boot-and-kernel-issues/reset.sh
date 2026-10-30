[ -f "$LAB_STATE/nginx.conf" ] && cp -a "$LAB_STATE/nginx.conf" /etc/nginx/nginx.conf
if [ -z "$(state_get nginx-was-active)" ]; then systemctl stop --quiet nginx 2>/dev/null; fi
[ -n "$(state_get nginx-was-enabled)" ] || systemctl disable --quiet nginx 2>/dev/null
systemctl reset-failed nginx 2>/dev/null
rm -f /etc/modprobe.d/local-hardening.conf
modprobe -r dummy 2>/dev/null
true
