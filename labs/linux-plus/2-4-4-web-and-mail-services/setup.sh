[ ! -e /srv/www ] || refuse "/srv/www already exists; move it away first"
for p in nginx httpd postfix s-nail mailutils; do pkg_installed $p && state_set had-$p 1; done
touch "$LAB_STATE/started"
