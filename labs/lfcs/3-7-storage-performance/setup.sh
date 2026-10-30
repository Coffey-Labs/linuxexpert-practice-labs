disk_add 0 1G >/dev/null
disk_add 1 256M >/dev/null
disk_add 2 256M >/dev/null
mkfs.ext4 -q /dev/loop40
mkdir -p /data
cat >/etc/systemd/system/data.mount <<'X'
[Unit]
Description=LINUXexpert practice lab test disk

[Mount]
What=/dev/loop40
Where=/data
Type=ext4

[Install]
WantedBy=local-fs.target
X
# The busy disk: a copy of dd under another name, reading /dev/loop42 over
# and over, held to a small share of the CPU.
cp "$(command -v dd)" /usr/local/sbin/reindexd
cat >/etc/systemd/system/le-lab-reindexd.service <<'X'
[Unit]
Description=LINUXexpert practice lab disk load
After=le-lab-disks.service

[Service]
CPUQuota=10%
ExecStart=/bin/sh -c 'while :; do /usr/local/sbin/reindexd if=/dev/loop42 of=/dev/null bs=64k iflag=direct status=none; done'

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet data.mount le-lab-reindexd.service

# The scheduler task starts from anything but mq-deadline.
if grep -q '\[mq-deadline\]' /sys/block/loop41/queue/scheduler; then
	echo none >/sys/block/loop41/queue/scheduler
fi
state_set scheduler "$(sed -n 's/.*\[\(.*\)\].*/\1/p' /sys/block/loop41/queue/scheduler)"

# sysstat collection off (Ubuntu turns it on when it's installed).
for u in sysstat sysstat-collect.timer sysstat-summary.timer; do
	if enabled "$u"; then
		printf '%s\n' "$u" >>"$LAB_STATE/sysstat-enabled"
		systemctl disable --now --quiet "$u"
	fi
done
true
