[ ! -e /root/shop.db ] || refuse "/root/shop.db already exists; move it away first"
for p in jq $(pick sqlite sqlite3); do
	pkg_installed "$p" || echo "$p" >>"$LAB_STATE/not-installed"
done
true
