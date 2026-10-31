installed_pkgs() { dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^.i/ {print $2}' | sort -u; }
[ -e /root/usb ] && refuse "/root/usb already exists; move it away first"
command -v gpgv >/dev/null || pkg_install gpgv
[ -f /usr/share/keyrings/ubuntu-archive-keyring.gpg ] || refuse "this lab needs /usr/share/keyrings/ubuntu-archive-keyring.gpg (package ubuntu-keyring)"
pkg_installed xorriso && state_set had-xorriso 1
installed_pkgs >"$LAB_STATE/pkgs-before"
disk_add 0 64M >/dev/null
mkdir /root/usb
