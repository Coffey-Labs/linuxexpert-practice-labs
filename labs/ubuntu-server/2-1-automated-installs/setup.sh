command -v cloud-init >/dev/null || refuse "cloud-init isn't installed; install it with: sudo apt install cloud-init"
for f in /root/cloud/user-data /root/cloud/autoinstall.yaml; do
	[ -e "$f" ] && refuse "$f already exists; move it away and start again"
done
[ -d /root/cloud ] || { mkdir -p /root/cloud; state_set made-dir 1; }
true
