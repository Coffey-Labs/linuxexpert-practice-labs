visudo -c >/dev/null 2>&1 || refuse "visudo -c finds a problem in the sudoers files; fix it and start the lab again."
user_add alice
user_add bob
cp -a /etc/sudoers "$LAB_STATE/sudoers"
ls -A /etc/sudoers.d >"$LAB_STATE/sudoers-d"
true
