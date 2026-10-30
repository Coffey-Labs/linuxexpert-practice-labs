rm -f /tmp/ok.txt /tmp/errors.txt /tmp/log.txt /tmp/confs.txt
sed -i '/[[:space:]]test\.example\.com\([[:space:]]\|$\)/d' /etc/hosts
true
