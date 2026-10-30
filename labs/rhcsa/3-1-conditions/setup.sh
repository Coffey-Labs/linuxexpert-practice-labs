pkg_installed chrony || pkg_install chrony
for f in kind amiroot userexists start-chronyd; do
	[ -e /usr/local/bin/$f ] && refuse "/usr/local/bin/$f already exists; the lab asks you to write it. Remove it and start the lab again."
done
true
