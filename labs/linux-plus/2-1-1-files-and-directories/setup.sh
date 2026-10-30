[ ! -e /root/lab ] || refuse "/root/lab already exists; move it away first"
command -v file >/dev/null || pkg_install file
true
