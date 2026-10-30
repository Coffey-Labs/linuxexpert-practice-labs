for f in /root/ai-cleanup.sh /root/cleanup.sh; do [ ! -e "$f" ] || refuse "$f already exists; move it away first"; done
true
