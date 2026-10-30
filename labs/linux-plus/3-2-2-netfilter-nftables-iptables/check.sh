T=$(nft list table inet lab 2>/dev/null)
# drops: packets counted by the rule that drops @blocked.
drops() { grep -E 'ip saddr @blocked .*counter packets [0-9]+ .*drop' <<<"$T" | grep -oE 'packets [0-9]+' | awk '{print $2}'; }

task 1 "Table inet lab with set blocked and chain input loaded"
need "table inet lab is loaded" '[ -n "$T" ]'
need "it has a set blocked of type ipv4_addr" 'grep -A2 "set blocked" <<<"$T" | grep -q "type ipv4_addr"'
need "chain input hooks input at priority 0 with policy accept" 'grep -Eq "type filter hook input priority (0|filter); policy accept;" <<<"$T"'
need "a rule counts and drops packets from @blocked" 'grep -Eq "ip saddr @blocked counter packets [0-9]+ bytes [0-9]+ drop" <<<"$T"'
need "a rule counts packets to TCP port 8080" 'grep -Eq "tcp dport 8080 counter packets" <<<"$T"'

task 2 "The peer blocked, and the drops counted"
need "10.99.0.2 is in the set blocked" 'nft list set inet lab blocked 2>/dev/null | grep -q "10\.99\.0\.2"'
need "the peer's ping gets no reply" '! in_peer ping -c1 -W2 10.99.0.1'
need "the drop rule has counted packets" '[ "$(drops)" -gt 0 ]'
