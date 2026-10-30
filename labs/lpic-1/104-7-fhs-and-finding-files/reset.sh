if [ -f "$LAB_STATE/updatedb.conf" ]; then cp -a "$LAB_STATE/updatedb.conf" /etc/updatedb.conf
else sed -i 's| /srv/archive/\?||' /etc/updatedb.conf 2>/dev/null; fi
rm -rf /srv/archive
command -v updatedb >/dev/null && updatedb
true
