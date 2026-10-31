# LPIC-3 334.4: Virtual private networks

A WireGuard tunnel, an OpenVPN tunnel with its own PKI, and an IPsec
connection, between this VM as the server and the peer as the client.
OpenVPN and strongSwan need an extra repository on the RHEL family, so
this lab runs on Ubuntu only.

## Before you start

The peer, at `10.99.0.2` (name `peer`), is the VPN client. It sits on this
VM's second network, `10.99.0.0/24`, where this VM is `10.99.0.1` on
interface `le-host`. It shares this VM's files and programs, so there is
nothing to copy over the network: write the client's files where the
tasks say, and the lab's units start the client in the peer.

- `le-lab-peer-wg.service` runs `wg-quick up` in the peer with
  `/etc/netns/lepeer/wireguard/wg0.conf`. (In a peer shell, made with
  `sudo ip netns exec lepeer bash`, that file is `/etc/wireguard/wg0.conf`.)
- `le-lab-peer-openvpn.service` runs OpenVPN in the peer with
  `/etc/netns/lepeer/openvpn/lab.conf`.
- `le-lab-peer-ipsec.service` already runs strongSwan in the peer, with
  its side of the IPsec connection set up: IKEv2 from `10.99.0.2` to
  `10.99.0.1`, its own ID `peer`, your ID `server`, the pre-shared key
  `lab-ipsec-psk-for-testing-only`, proposals
  `aes256gcm16-prfsha256-ecp256` (IKE) and `aes256gcm16-ecp256` (ESP),
  transport mode, started by traffic (`trap`). Its configuration is in
  `/etc/le-lab-peer-ipsec/`.

The firewall, if it's running, is yours to open. Keep your PKI and keys
under `/root/vpn`.

## Tasks

1. Install `wireguard-tools`, `openvpn` and `easy-rsa` (setup installed
   strongSwan already, for the peer). Make WireGuard keys for both ends,
   private keys straight into files, never shown. Bring up `wg0` here,
   `10.40.0.1/24` on port 51820, with the peer allowed as `10.40.0.2/32`,
   from `/etc/wireguard/wg0.conf` readable by root only, and make it start
   at boot. Write the client configuration (`10.40.0.2/24`, endpoint
   `10.99.0.1:51820`, allowed `10.40.0.0/24`, a keepalive), and enable and
   start `le-lab-peer-wg.service`. The peer must reach `10.40.0.1`.
2. Build an OpenVPN PKI with easy-rsa in `/root/vpn/ca`: a CA, a server
   certificate `server` and a client certificate `peer`, and a
   `tls-crypt` key. Run a routed server, `openvpn-server@lab`, on UDP port
   1194 for `10.8.0.0/24` (subnet topology, no DH parameters, dropping
   privileges to `nobody`), enabled at boot.
3. Write the client's configuration with everything inline (CA,
   certificate, key and `tls-crypt` key), checking that the server's
   certificate is a server certificate, and enable and start
   `le-lab-peer-openvpn.service`. The peer must reach `10.8.0.1`.
4. Set up this VM's side of the IPsec connection with swanctl to match the
   peer's, in `/etc/swanctl/conf.d/`, load it, and bring it up. Traffic
   between `10.99.0.1` and `10.99.0.2` must then travel as ESP.

## Hints

- `wg genkey | tee KEY | wg pubkey > PUB`, `umask 077`; `[Interface]`
  (`Address`, `ListenPort`, `PrivateKey`) and `[Peer]` (`PublicKey`,
  `AllowedIPs`, `Endpoint`, `PersistentKeepalive`);
  `systemctl enable --now wg-quick@wg0`, `wg show`.
- `make-cadir`, `EASYRSA_BATCH=1 ./easyrsa init-pki`, `build-ca nopass`,
  `build-server-full server nopass`, `build-client-full peer nopass`;
  `openvpn --genkey secret ta.key`. Files in `/etc/openvpn/server/`:
  `server 10.8.0.0 255.255.255.0`, `topology subnet`, `dh none`,
  `tls-crypt ta.key`, `user nobody`, `group nogroup`.
- `client`, `dev tun`, `remote 10.99.0.1 1194`, `remote-cert-tls server`,
  then `<ca>...</ca>`, `<cert>`, `<key>`, `<tls-crypt>` blocks.
  `journalctl -u le-lab-peer-openvpn`.
- `connections { NAME { version = 2; local_addrs; remote_addrs;
  proposals; local { auth = psk; id = server } remote { ... } children {
  NAME { mode = transport; esp_proposals; start_action = trap } } } }` and
  `secrets { ike-NAME { id-a = server; id-b = peer; secret = "..." } }`;
  `systemctl restart strongswan`, `swanctl --load-all`, `swanctl
  --initiate --child NAME`, `swanctl --list-sas`, `ip xfrm policy`,
  `tcpdump -ni le-host esp`.
