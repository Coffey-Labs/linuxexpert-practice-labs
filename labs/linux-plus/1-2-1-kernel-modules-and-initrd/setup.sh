if grep -rqsw dummy /etc/modules-load.d /etc/modprobe.d /etc/modules; then
	refuse "/etc/modules-load.d or /etc/modprobe.d already mentions dummy; remove that first"
fi
modprobe -r dummy 2>/dev/null || true
