rm -rf /root/repo
[ -n "$(state_get had-gitconfig)" ] || rm -f /root/.gitconfig
true
