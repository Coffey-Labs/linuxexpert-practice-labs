command -v snap >/dev/null || refuse "this lab needs snapd (apt install snapd)"
snap list htop >/dev/null 2>&1 && refuse "the htop snap is installed; remove it first (snap remove --purge htop)"
pkg_installed htop && state_set had-htop 1
pkg_installed ubuntu-server && state_set had-ubuntu-server 1
[ -e /root/.config/htop/htoprc ] && state_set had-htoprc 1
# Snapshots of htop from before the lab don't count for task 3.
snap saved htop 2>/dev/null | awk 'NR > 1 && $2 == "htop" {print $1}' >"$LAB_STATE/old-snapshots"
true
