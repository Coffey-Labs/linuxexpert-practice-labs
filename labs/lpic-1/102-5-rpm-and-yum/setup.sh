rpm -q openssh-server >/dev/null || refuse "openssh-server isn't installed; this lab needs it."
if rpm -q bind-utils >/dev/null 2>&1; then
	refuse "bind-utils is installed already, and task 3 installs it; remove it with: sudo dnf remove bind-utils, then start the lab again."
fi
grep -q '^# le-lab 102.5' /etc/ssh/sshd_config || echo '# le-lab 102.5: a change for rpm -V to find' >>/etc/ssh/sshd_config
state_set history "$(dnf -q history list 2>/dev/null | awk '$1 ~ /^[0-9]+$/ {print $1; exit}')"
