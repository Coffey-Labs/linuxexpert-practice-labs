pkill -f 's_server -accept 8443' 2>/dev/null
rm -rf /root/pki /root/f.txt /root/f.sha256
if is_rhel; then
	rm -f /etc/pki/ca-trust/source/anchors/lab-ca.crt
	update-ca-trust
else
	rm -f /usr/local/share/ca-certificates/lab-ca.crt
	update-ca-certificates --fresh >/dev/null
fi
true
