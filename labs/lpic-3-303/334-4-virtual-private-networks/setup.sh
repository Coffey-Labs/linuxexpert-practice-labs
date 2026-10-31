for p in /root/vpn /etc/wireguard/wg0.conf /etc/openvpn/server/lab.conf /etc/swanctl/conf.d/lab.conf; do
	[ -e $p ] && refuse "$p already exists; move it away and start again"
done
ip link show wg0 >/dev/null 2>&1 && refuse "an interface wg0 already exists; take it down and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
active strongswan && state_set strongswan-was-active 1
if command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
peer_up

# The peer's strongSwan: its own charon, with its own control socket.
pkg_install charon-systemd strongswan-swanctl
mkdir -p /etc/le-lab-peer-ipsec /etc/netns/lepeer/wireguard /etc/netns/lepeer/openvpn
cat >/etc/le-lab-peer-ipsec/strongswan.conf <<'X'
# The peer's strongSwan: like the system's, with its own control socket.
charon {
    load_modular = yes
    plugins {
        include /etc/strongswan.d/charon/*.conf
        vici {
            socket = unix:///run/le-lab-peer-charon.vici
        }
    }
}
charon-systemd {
    load_modular = yes
    plugins {
        include /etc/strongswan.d/charon/*.conf
        vici {
            socket = unix:///run/le-lab-peer-charon.vici
        }
    }
}
X
cat >/etc/le-lab-peer-ipsec/swanctl.conf <<'X'
connections {
    host-host {
        version = 2
        local_addrs = 10.99.0.2
        remote_addrs = 10.99.0.1
        proposals = aes256gcm16-prfsha256-ecp256
        local {
            auth = psk
            id = peer
        }
        remote {
            auth = psk
            id = server
        }
        children {
            host-host {
                mode = transport
                esp_proposals = aes256gcm16-ecp256
                start_action = trap
            }
        }
    }
}
secrets {
    ike-lab {
        id-server = server
        id-peer = peer
        secret = "lab-ipsec-psk-for-testing-only"
    }
}
X
chmod 600 /etc/le-lab-peer-ipsec/swanctl.conf
cat >/etc/systemd/system/le-lab-peer-ipsec.service <<'X'
[Unit]
Description=Practice lab: strongSwan on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
Type=notify
NetworkNamespacePath=/run/netns/lepeer
# swanctl's AppArmor profile only allows the system's control socket.
AppArmorProfile=unconfined
ExecStart=/usr/bin/env STRONGSWAN_CONF=/etc/le-lab-peer-ipsec/strongswan.conf /usr/sbin/charon-systemd
ExecStartPost=/usr/sbin/swanctl --load-all --noprompt --file /etc/le-lab-peer-ipsec/swanctl.conf --uri unix:///run/le-lab-peer-charon.vici
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-wg.service <<'X'
[Unit]
Description=Practice lab: the peer's WireGuard client
Requires=le-lab-peer.service
After=le-lab-peer.service network.target
ConditionPathExists=/etc/netns/lepeer/wireguard/wg0.conf

[Service]
Type=oneshot
RemainAfterExit=yes
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/bin/wg-quick up /etc/netns/lepeer/wireguard/wg0.conf
ExecStop=/usr/bin/wg-quick down /etc/netns/lepeer/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-openvpn.service <<'X'
[Unit]
Description=Practice lab: the peer's OpenVPN client
Requires=le-lab-peer.service
After=le-lab-peer.service network.target
ConditionPathExists=/etc/netns/lepeer/openvpn/lab.conf

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/sbin/openvpn --config /etc/netns/lepeer/openvpn/lab.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-ipsec.service
