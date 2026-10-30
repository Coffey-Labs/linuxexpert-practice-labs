# Take the CA back out of the system trust store.
if [ -f /root/tls/ca.crt ]; then
	fp=$(openssl x509 -in /root/tls/ca.crt -noout -fingerprint -sha256 2>/dev/null)
	for f in /etc/pki/ca-trust/source/anchors/* /usr/local/share/ca-certificates/*.crt /usr/local/share/ca-certificates/*/*.crt; do
		[ -f "$f" ] || continue
		[ "$(openssl x509 -in "$f" -noout -fingerprint -sha256 2>/dev/null)" = "$fp" ] && rm -f "$f"
	done
fi
if is_rhel; then update-ca-trust 2>/dev/null; else update-ca-certificates --fresh >/dev/null 2>&1; fi
rm -rf /root/tls
rm -f /etc/pki/tls/certs/web1*.crt /etc/pki/tls/private/web1*.key /etc/ssl/certs/web1*.crt /etc/ssl/private/web1*.key
if [ -d "$LAB_STATE/nginx.orig" ]; then
	rm -rf /etc/nginx
	cp -a "$LAB_STATE/nginx.orig" /etc/nginx
	is_rhel && restorecon -R /etc/nginx 2>/dev/null
fi
systemctl restart nginx 2>/dev/null
true
