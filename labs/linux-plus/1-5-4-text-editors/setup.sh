rm -f /tmp/s.conf
# The startup files task 4 may change, for reset to put back.
saved=$LAB_STATE/saved
for f in /etc/environment /etc/profile.d /root/.bashrc /root/.bash_profile /root/.profile /root/.selected_editor \
	/home/*/.bashrc /home/*/.bash_profile /home/*/.profile /home/*/.selected_editor; do
	if [ -e "$f" ]; then
		mkdir -p "$saved${f%/*}"
		cp -a "$f" "$saved$f"
		printf '%s\n' "$f" >>"$LAB_STATE/kept"
	else
		printf '%s\n' "$f" >>"$LAB_STATE/absent"
	fi
done
# The README has the student install full Vim and nano on the RHEL family;
# note which are missing, for reset to remove.
if is_rhel; then
	for p in vim-enhanced nano; do pkg_installed $p || printf '%s\n' $p >>"$LAB_STATE/missing-pkgs"; done
fi
true
