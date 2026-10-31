KEYF=$(pick /etc/named/lab-key.conf /etc/bind/lab-key.conf)
A=10.99.0.1
# pdig ARGS: dig from the peer, at this VM.
pdig() { in_peer dig @$A +time=3 +tries=1 "$@" 2>/dev/null; }
# signed ZONE NAME TYPE: the answer comes with an RRSIG.
signed() { pdig "$2" "$3" +dnssec +norec | grep -Eq "^$2\.?[[:space:]].*IN[[:space:]]+RRSIG[[:space:]]+$3 "; }
dnskeys() { pdig "$1" DNSKEY +norec +short | awk '{print $1}' | sort -u | tr '\n' ' '; }
validated() { in_peer timeout 20 delv @$A -a /root/dns/lab-anchors.conf +root="$1" "www.$1" 2>&1 | grep -q "; fully validated"; }

task 1 "Authoritative-only BIND serving lab.test, signed with NSEC3"
need "BIND is running and enabled" 'active named && enabled named'
need "the peer gets an authoritative answer for lab.test SOA from 10.99.0.1" 'for i in $(seq 15); do pdig lab.test SOA +norec | grep -q "flags:.* aa" && exit 0; sleep 1; done; exit 1'
need "it answers on 127.0.0.1 too" 'dig @127.0.0.1 +time=3 +tries=1 lab.test SOA +norec | grep -q "flags:.* aa"'
need "recursion is off (no ra flag)" '! pdig www.lab.test A | grep -q "flags:[^;]* ra[ ;]"'
need "www.lab.test and ns1.lab.test are 10.99.0.1" '[ "$(pdig www.lab.test A +short)" = 10.99.0.1 ] && [ "$(pdig ns1.lab.test A +short)" = 10.99.0.1 ]'
need "the NS record is ns1.lab.test." '[ "$(pdig lab.test NS +short)" = ns1.lab.test. ]'
need "the three CAA records are there" 'c=$(pdig lab.test CAA +short); grep -q "0 issue \"letsencrypt.org\"" <<<"$c" && grep -q "0 issuewild \";\"" <<<"$c" && grep -q "0 iodef \"mailto:security@lab.test\"" <<<"$c"'
need "lab.test has a KSK (257) and a ZSK (256)" 'for i in $(seq 10); do [ "$(dnskeys lab.test)" = "256 257 " ] && exit 0; sleep 1; done; exit 1'
need "www.lab.test comes with an RRSIG" 'signed lab.test www.lab.test A'
need "a missing name is denied with NSEC3" 'pdig nothere.lab.test A +dnssec +norec | grep -q "NXDOMAIN" && pdig nothere.lab.test A +dnssec +norec | grep -Eq "IN[[:space:]]+NSEC3[[:space:]]"'

task 2 "manual.test signed by hand, with NSEC"
need "the server answers for manual.test" 'pdig manual.test SOA +norec | grep -q "flags:.* aa"'
need "www.manual.test is 10.99.0.1" '[ "$(pdig www.manual.test A +short)" = 10.99.0.1 ]'
need "manual.test has a KSK (257) and a ZSK (256)" '[ "$(dnskeys manual.test)" = "256 257 " ]'
need "www.manual.test comes with an RRSIG" 'signed manual.test www.manual.test A'
need "a missing name is denied with NSEC" 'pdig nothere.manual.test A +dnssec +norec | grep -Eq "IN[[:space:]]+NSEC[[:space:]]"'

task 3 "TSIG key lab-key for transfers and updates; mail.lab.test added"
need "the key file defines lab-key" 'grep -Eq "key \"?lab-key\"?" $KEYF && grep -q hmac-sha256 $KEYF'
need "a transfer of lab.test without the key is refused" '! pdig lab.test AXFR | grep -Eq "IN[[:space:]]+SOA"'
need "a transfer with the key works" 'pdig -k $KEYF lab.test AXFR | grep -Eq "IN[[:space:]]+RRSIG"'
need "mail.lab.test is 10.99.0.3, signed" '[ "$(pdig mail.lab.test A +short)" = 10.99.0.3 ] && signed lab.test mail.lab.test A'
need "updates without the key are refused" 'conf=$(named-checkconf -p 2>/dev/null); ! grep -Eq "allow-update[[:space:]]*\{[^}]*(any|10\.|127\.|localhost|localnets)" <<<"$conf"'

task 4 "Trust anchors validate both zones from the peer"
need "/root/dns/lab-anchors.conf has static-ds entries for both zones" 'grep -Eq "lab\.test\.?[[:space:]]+static-ds" /root/dns/lab-anchors.conf && grep -Eq "manual\.test\.?[[:space:]]+static-ds" /root/dns/lab-anchors.conf'
need "delv fully validates www.lab.test" 'validated lab.test'
need "delv fully validates www.manual.test" 'validated manual.test'

task 5 "DANE: TLSA 3 1 1 for the service on port 4433"
need "/root/dns/www.crt and www.key are a pair" '[ -n "$(openssl x509 -in /root/dns/www.crt -noout -pubkey 2>/dev/null)" ] && [ "$(openssl x509 -in /root/dns/www.crt -noout -pubkey)" = "$(openssl pkey -in /root/dns/www.key -pubout 2>/dev/null)" ]'
need "_4433._tcp.www.lab.test has a signed 3 1 1 TLSA record" 'pdig _4433._tcp.www.lab.test TLSA +short | grep -q "^3 1 1 " && signed lab.test _4433._tcp.www.lab.test TLSA'
need "the TLSA record matches www.crt" 'h=$(openssl x509 -in /root/dns/www.crt -noout -pubkey | openssl pkey -pubin -outform DER | sha256sum | cut -d" " -f1); pdig _4433._tcp.www.lab.test TLSA +short | tr -d " " | tr A-F a-f | grep -qx "311$h"'
need "the peer reaches a TLS service on 10.99.0.1:4433" 'for i in $(seq 10); do in_peer timeout 5 openssl s_client -connect $A:4433 </dev/null 2>/dev/null | grep -q "BEGIN CERTIFICATE" && exit 0; sleep 1; done; exit 1'
need "s_client verifies it with DANE" 't=$(pdig _4433._tcp.www.lab.test TLSA +short | awk "{ d = \"\"; for (i = 4; i <= NF; i++) d = d \$i; print \$1, \$2, \$3, d }"); in_peer timeout 5 openssl s_client -connect $A:4433 -dane_tlsa_domain www.lab.test -dane_tlsa_rrdata "$t" </dev/null 2>&1 | grep -q "Verification: OK"'

task 6 "DNS over TLS on 10.99.0.1:853"
need "dig +tls from the peer gets www.lab.test" 'for i in $(seq 10); do [ "$(pdig +tls www.lab.test A +short)" = 10.99.0.1 ] && exit 0; sleep 1; done; exit 1'
