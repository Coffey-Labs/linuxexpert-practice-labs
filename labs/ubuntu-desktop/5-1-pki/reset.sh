rm -f /etc/ca-certificates/update.d/le-lab-log
changed=
while read -r f; do
	grep -qxF "$f" "$LAB_STATE/local-cas" 2>/dev/null && continue
	rm -f "$f"; changed=1
done < <(find /usr/local/share/ca-certificates -type f 2>/dev/null)
[ -n "$changed" ] && update-ca-certificates --fresh >/dev/null 2>&1
# Servers on 4433 that task 2 started.
for pid in $(ss -Hltnp 'sport = :4433' 2>/dev/null | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u); do
	[ "$(cat /proc/$pid/comm 2>/dev/null)" = openssl ] && kill "$pid" 2>/dev/null
done
rm -rf /root/pki
true
