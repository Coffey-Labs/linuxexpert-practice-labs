for p in /root/project /root/app.git /root/app-copy; do
	[ ! -e "$p" ] || refuse "$p already exists; move it away first"
done
[ -e /root/.gitconfig ] && state_set had-gitconfig 1
pkg_installed git || state_set no-git 1
true
