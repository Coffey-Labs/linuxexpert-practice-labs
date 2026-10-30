ip link show lab0 >/dev/null 2>&1 && refuse "an interface lab0 already exists; delete it and start again"
peer_up
# Task 2: the peer's side takes only 1400-byte packets.
ip -n lepeer link set le-peer mtu 1400
# Task 4: the peer already uses 10.99.0.5.
ip -n lepeer addr add 10.99.0.5/24 dev le-peer 2>/dev/null || true
state_set peer-mac "$(ip -n lepeer -o link show le-peer | grep -oE 'link/ether [0-9a-f:]+' | cut -d' ' -f2)"
# Task 1: the link is down.
ip link set le-host down
true
