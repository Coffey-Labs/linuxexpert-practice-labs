sed -i '/^# le-lab 102.5/d' /etc/ssh/sshd_config
rm -rf /root/rpms
rpm -q bind-utils >/dev/null 2>&1 && dnf -y -q remove bind-utils >/dev/null 2>&1
true
