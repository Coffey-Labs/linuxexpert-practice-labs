for p in postfix exim4 exim4-daemon-light sendmail; do
	pkg_installed "$p" && refuse "an MTA ($p) is installed already; this lab installs Postfix. Remove it first."
done
user_add alice
user_add bob
for p in s-nail mailx mailutils bsd-mailx; do
	pkg_installed "$p" && echo "$p" >>"$LAB_STATE/had-pkgs"
done
[ -f /etc/aliases ] && cp -a /etc/aliases "$LAB_STATE/aliases"
true
