for f in /etc/httpd/conf.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/conf-d" 2>/dev/null && continue
	grep -q '/web' "$f" && rm -f "$f"
done
if command -v semanage >/dev/null; then
	semanage fcontext -l -C 2>/dev/null | awk '$1 ~ /^\/web/ {print $1}' | sort -u |
		while read -r spec; do semanage fcontext -d "$spec" 2>/dev/null; done
fi
rm -rf /web /var/www/html/page.html /var/www/html/label.html /tmp/page.html
if [ -n "$(state_get httpd-was-enabled)" ]; then systemctl restart httpd 2>/dev/null
else systemctl disable --now --quiet httpd 2>/dev/null; fi
true
