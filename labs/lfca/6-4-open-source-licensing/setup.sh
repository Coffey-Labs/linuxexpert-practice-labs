[ ! -e /root/practice-repo ] || refuse "/root/practice-repo already exists; move it away first"
[ -e /root/.gitconfig ] && state_set had-gitconfig 1
pkg_installed git || state_set no-git 1
true
