rm -f /usr/local/sbin/diskcheck /root/checkfiles.sh /root/count.sh /root/service.sh
# Root's mail as it was.
for f in /var/mail/root /var/spool/mail/root /root/mbox; do
	s="$LAB_STATE/mail/$(echo "$f" | tr / _)"
	if [ -f "$s" ]; then cp -a "$s" "$f"; elif [ -f "$f" ]; then rm -f "$f"; fi
done
true
