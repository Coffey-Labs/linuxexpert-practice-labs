pkg_install sysstat
peer_up
mkdir -p /usr/local/lib/le-lab /var/lib/log-shipper
# Task 1: a service that writes small synchronous blocks all the time.
cat >/usr/local/lib/le-lab/log-shipper.py <<'Y'
import os, time
open("/proc/self/comm", "w").write("log-shipper")
fd = os.open("/var/lib/log-shipper/spool.dat", os.O_WRONLY | os.O_CREAT | os.O_DSYNC, 0o600)
block = b"x" * 4096
n = 0
while True:
    os.pwrite(fd, block, (n % 2048) * 4096)
    n += 1
    time.sleep(0.004)
Y
cat >/etc/systemd/system/log-shipper.service <<'Y'
[Unit]
Description=Log shipper

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/log-shipper.py

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --now --quiet log-shipper.service
# Task 2: 80 ms of delay on this VM's side; task 3: 40 Mbit/s on the peer's.
tc qdisc replace dev le-host root netem delay 80ms 10ms
ip netns exec lepeer tc qdisc replace dev le-peer root tbf rate 40mbit burst 64kb latency 50ms
if systemctl is-active --quiet firewalld; then
	firewall-cmd -q --query-port=5201/tcp && state_set port-open 1
	firewall-cmd -q --permanent --query-port=5201/tcp && state_set port-open-permanent 1
fi
true
