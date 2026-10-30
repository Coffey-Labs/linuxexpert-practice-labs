id ops >/dev/null 2>&1 && refuse "user ops already exists; remove it and start again"
[ -e /usr/local/sbin/labtool ] && refuse "/usr/local/sbin/labtool already exists; remove it and start again"
state_set start "$(date +%s)"
if [ ! -d /var/log/journal ]; then
	mkdir -p /var/log/journal
	systemd-tmpfiles --create --prefix /var/log/journal
	journalctl --flush
	state_set made-journal 1
fi
# Task 3: a worker, stopped.
mkdir -p /usr/local/lib/le-lab /var/lib/queue-worker
cat >/usr/local/lib/le-lab/queue-worker <<'Y'
#!/bin/bash
n=0
while :; do
	n=$((n + 1))
	echo $n >/var/lib/queue-worker/count
	sleep 1
done
Y
chmod 755 /usr/local/lib/le-lab/queue-worker
cat >/etc/systemd/system/queue-worker.service <<'Y'
[Unit]
Description=Queue worker

[Service]
ExecStart=/usr/local/lib/le-lab/queue-worker
Y
systemctl daemon-reload
systemctl start queue-worker.service
sleep 2
pid=$(systemctl show -p MainPID --value queue-worker.service)
kill -STOP "$pid"
state_set worker-pid "$pid"
# Task 4: a cron job whose command isn't on cron's PATH.
install -m 755 /dev/stdin /usr/local/sbin/labtool <<'Y'
#!/bin/bash
echo labtool ran
Y
user_add ops
echo '* * * * * labtool >> /home/ops/labtool.log 2>&1' | crontab -u ops -
true
