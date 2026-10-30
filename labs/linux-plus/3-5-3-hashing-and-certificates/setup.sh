[ -e /root/pki ] && refuse "/root/pki already exists; move it away and start again"
rm -f /root/f.txt /root/f.sha256
true
