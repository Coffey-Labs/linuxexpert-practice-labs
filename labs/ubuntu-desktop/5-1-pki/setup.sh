[ -e /root/pki ] && refuse "/root/pki already exists; move it away first"
command -v update-ca-certificates >/dev/null || pkg_install ca-certificates
command -v openssl >/dev/null || pkg_install openssl
command -v curl >/dev/null || pkg_install curl
mkdir -p /usr/local/share/ca-certificates
find /usr/local/share/ca-certificates -type f | sort >"$LAB_STATE/local-cas"
mkdir -p /etc/ca-certificates/update.d
cat >/etc/ca-certificates/update.d/le-lab-log <<HOOK
#!/bin/sh
# LINUXexpert practice lab: note the certificates update-ca-certificates
# adds, by fingerprint. Removed by le-lab reset.
while read -r line; do
	case \$line in
	+*) openssl x509 -noout -fingerprint -sha256 -in "\${line#+}" 2>/dev/null >>"$LAB_STATE/ca-added" ;;
	esac
done
exit 0
HOOK
chmod 755 /etc/ca-certificates/update.d/le-lab-log
mkdir /root/pki
