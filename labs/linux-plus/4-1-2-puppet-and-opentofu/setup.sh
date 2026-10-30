for f in /root/lab.pp /root/tofu /tmp/puppet-lab.txt; do [ ! -e "$f" ] || refuse "$f already exists; move it away first"; done
true
