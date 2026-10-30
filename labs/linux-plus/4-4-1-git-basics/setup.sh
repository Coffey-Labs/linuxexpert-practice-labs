[ ! -e /root/repo ] || refuse "/root/repo already exists; move it away first"
[ -e /root/.gitconfig ] && state_set had-gitconfig 1
true
