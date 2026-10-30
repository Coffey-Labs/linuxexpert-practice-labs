[ -e /etc/modprobe.d/local-hardening.conf ] && refuse "/etc/modprobe.d/local-hardening.conf already exists; move it away and start again"
pkg_installed nginx && state_set had-nginx 1
pkg_install nginx
cp -a /etc/nginx/nginx.conf "$LAB_STATE/nginx.conf"
systemctl is-active --quiet nginx && state_set nginx-was-active 1
systemctl is-enabled --quiet nginx 2>/dev/null && state_set nginx-was-enabled 1
# Task 1: a bad line.
echo 'this is not valid;' >>/etc/nginx/nginx.conf
state_set bad-line "$(wc -l </etc/nginx/nginx.conf)"
systemctl enable --quiet nginx
systemctl restart nginx 2>/dev/null || true
# Task 2: a rule that stops the dummy driver from loading.
modprobe -r dummy 2>/dev/null || true
cat >/etc/modprobe.d/local-hardening.conf <<'Y'
# Local hardening: drivers we don't use.
install dummy /bin/false
Y
true
