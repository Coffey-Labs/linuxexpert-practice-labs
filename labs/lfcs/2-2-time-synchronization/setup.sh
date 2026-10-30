tz=$(timedatectl show -p Timezone --value)
state_set tz "$tz"
[ "$tz" != Europe/Berlin ] || timedatectl set-timezone UTC
peer_up

if is_rhel; then
	pkg_installed chrony || pkg_install chrony
	cp -a /etc/chrony.conf "$LAB_STATE/chrony.conf"
	systemctl enable --now chronyd
else
	# Task 3 needs systemd-timesyncd, not chrony.
	pkg_installed systemd-timesyncd || pkg_install systemd-timesyncd
	cp -a /etc/systemd/timesyncd.conf "$LAB_STATE/timesyncd.conf"
	ls /etc/systemd/timesyncd.conf.d >"$LAB_STATE/timesyncd-d" 2>/dev/null || true
	systemctl stop systemd-timedated 2>/dev/null # rereads the NTP services when it starts again
	systemctl enable --now --quiet systemd-timesyncd
	timedatectl set-ntp true 2>/dev/null || true

	# A small NTP server on the peer for task 5.
	mkdir -p /usr/local/lib/le-lab
	cat >/usr/local/lib/le-lab/ntp-server.py <<'X'
# A minimal NTP server for the practice lab: answers every client request
# with this machine's clock.
import socket, struct, time

EPOCH = 2208988800


def stamp(t):
    return struct.pack("!II", int(t) + EPOCH, int((t % 1) * 2**32))


s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("10.99.0.2", 123))
while True:
    data, addr = s.recvfrom(1024)
    if len(data) < 48 or data[0] & 7 != 3:
        continue
    now = time.time()
    version = (data[0] >> 3) & 7
    reply = struct.pack("!BBbb", (version << 3) | 4, 2, data[2], -20)
    reply += struct.pack("!II", 0x100, 0x100) + b"LABS" + stamp(now - 8)
    reply += data[40:48] + stamp(now) + stamp(time.time())
    s.sendto(reply, addr)
X
	cat >/etc/systemd/system/le-lab-ntp.service <<'X'
[Unit]
Description=Practice lab NTP server on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service
Before=chrony.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/ntp-server.py

[Install]
WantedBy=multi-user.target
X
	systemctl daemon-reload
	systemctl enable --now --quiet le-lab-ntp.service
fi

# Save the firewall's configuration, if one runs, for reset.
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
