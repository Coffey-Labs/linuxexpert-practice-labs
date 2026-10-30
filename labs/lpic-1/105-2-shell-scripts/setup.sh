# The chapter's diskcheck script.
cat >/usr/local/sbin/diskcheck <<'X'
#!/bin/bash
# diskcheck: mail root when a filesystem is fuller than the limit (default 90%)
limit=${1:-90}
report=""
while read -r pct mount; do
    pct=${pct%\%}                       # "93%" becomes "93"
    if [ "$pct" -gt "$limit" ]; then
        report+="$mount is ${pct}% full"$'\n'
    fi
done < <(df --output=pcent,target -x tmpfs -x devtmpfs -x squashfs -x overlay | tail -n +2)

if [ -n "$report" ]; then
    printf '%s' "$report" | mail -s "Disk space on $(hostname)" root
fi
X
chmod 755 /usr/local/sbin/diskcheck

# Root's mail, set aside so only new messages count.
mkdir -p "$LAB_STATE/mail"
for f in /var/mail/root /var/spool/mail/root /root/mbox; do
	[ -f "$f" ] || continue
	cp -a "$f" "$LAB_STATE/mail/$(echo "$f" | tr / _)"
	: >"$f"
done
rm -f /root/checkfiles.sh /root/count.sh /root/service.sh
true
