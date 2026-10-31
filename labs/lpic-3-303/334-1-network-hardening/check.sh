A=10.99.0.1 SECRET=lab-radius-secret
rt() { in_peer timeout 15 radtest "$@" $A 0 $SECRET 0 10.99.0.2 2>/dev/null; }
SVC=$(pick radiusd freeradius)
count() { tshark -r /root/radius.pcapng -Y "$1" 2>/dev/null | grep -c .; }

task 1 "FreeRADIUS accepts alice from the peer's network"
need "the RADIUS server is running and enabled" "active $SVC && enabled $SVC"
need "radtest alice with the right password is accepted, with the reply Hello, alice" 'rt alice alice-lab-pass >/tmp/le-rt; grep -q "Received Access-Accept" /tmp/le-rt && grep -q "Hello, alice" /tmp/le-rt'
need "radtest alice with a wrong password is rejected" 'rt alice le-wrong-pass | grep -q "Received Access-Reject"'
need "radtest -t mschap alice is accepted" 'rt -t mschap alice alice-lab-pass | grep -q "Received Access-Accept"'
rm -f /tmp/le-rt

task 2 "/root/radius.pcapng holds an accept and a reject"
need "tshark is installed" 'command -v tshark'
need "/root/radius.pcapng has Access-Requests" '[ "$(count "radius.code == 1")" -gt 0 ]'
need "it has an Access-Accept" '[ "$(count "radius.code == 2")" -gt 0 ]'
need "it has an Access-Reject" '[ "$(count "radius.code == 3")" -gt 0 ]'

task 3 "Rogue router found and stopped"
need "the peer got an address in fd00:bad:30::/64" 'in_peer ip -6 addr show dev le-peer | grep -q "inet6 fd00:bad:30:"'
need "/root/lab-answers/3 has the MAC address of le-host" '[ "$(answer 3)" = "$(cat /sys/class/net/le-host/address)" ]'
need "radvd isn't running" '! active radvd && ! pgrep -x radvd'
need "the peer has no IPv6 default route" '! in_peer ip -6 route show default | grep -q .'
need "forwarding on le-host is off" '[ "$(sysctl -n net.ipv6.conf.le-host.forwarding)" = 0 ]'

task 4 "The rogue DHCP server's router, in /root/lab-answers/4"
need "/root/lab-answers/4 has the router the rogue offers" '[ "$(answer 4)" = "$(state_get router)" ]'
