R=$(ip -4 route get 9.9.9.9 2>/dev/null)
GW=$(awk '{for (i = 1; i < NF; i++) if ($i == "via") print $(i + 1)}' <<<"$R")
DEV=$(awk '{for (i = 1; i < NF; i++) if ($i == "dev") print $(i + 1)}' <<<"$R")
NET=/etc/netns/lepeer/network

task 1 "The gateway and interface to 9.9.9.9"
need "/root/lab-answers/1 has the gateway address" '[ -n "$GW" ] && grep -qw "${GW//./\\.}" /root/lab-answers/1'
need "it has the interface" '[ -n "$DEV" ] && grep -qw "$DEV" /root/lab-answers/1'

task 2 "The peer reaches 198.51.100.9, now and at boot"
need "the peer can ping 198.51.100.9" 'in_peer ping -c1 -W2 198.51.100.9'
need "the peer's default route is via 10.99.0.1" 'in_peer ip route show default | grep -q "via 10\.99\.0\.1 "'
need "$NET adds a default route via 10.99.0.1 and doesn't delete it" 'grep -Eq "^[^#]*route (add|replace|append) default via 10\.99\.0\.1([[:space:]]|$)" $NET && ! grep -Eq "^[^#]*route (del|delete|flush)" $NET'

task 3 "www.kernel.org resolves correctly again"
need "/root/lab-answers/3 names the source" 'grep -q "/etc/hosts" /root/lab-answers/3'
need "/etc/hosts has no 192.0.2.99 line" '! grep -q "^192\.0\.2\.99[[:space:]]" /etc/hosts'
need "getent hosts www.kernel.org doesn't give 192.0.2.99" '! getent hosts www.kernel.org | grep -q 192\.0\.2\.99'
