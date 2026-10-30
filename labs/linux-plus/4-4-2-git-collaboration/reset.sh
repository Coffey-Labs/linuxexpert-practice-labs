rm -rf /root/repo /root/repo2 /root/remote.git
[ -n "$(state_get had-gitconfig)" ] || rm -f /root/.gitconfig
true
