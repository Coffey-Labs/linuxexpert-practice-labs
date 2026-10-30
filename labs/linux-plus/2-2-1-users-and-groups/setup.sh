for u in labuser labsvc; do ! id "$u" >/dev/null 2>&1 || refuse "user $u already exists; remove it first"; done
! getent group labgroup >/dev/null || refuse "group labgroup already exists; remove it first"
[ ! -e /etc/skel/bin ] || refuse "/etc/skel/bin already exists; remove it first"
true
