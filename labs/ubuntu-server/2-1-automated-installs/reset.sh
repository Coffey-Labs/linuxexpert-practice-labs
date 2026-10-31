rm -f /root/cloud/user-data /root/cloud/autoinstall.yaml
[ -n "$(state_get made-dir)" ] && rm -rf /root/cloud
true
