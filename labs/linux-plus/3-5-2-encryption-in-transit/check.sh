P=/root/lab-answers/3.pcap

task 1 "The protocol www.kernel.org negotiated"
need "/root/lab-answers/1 has the TLS version" 'answer 1 | grep -Eq "^(new, |protocol *: *)?tlsv?1\.3"'

task 2 "The current crypto policy" rhel
need "/root/lab-answers/2 has its name" '[ -n "$(answer 2)" ] && [ "$(answer 2)" = "$(update-crypto-policies --show | tr A-Z a-z)" ]'

task 3 "A capture with the clear-text header"
need "$P is a capture tcpdump can read" "tcpdump -n -r $P"
need "it has the request to port 8000" "tcpdump -nn -r $P 2>/dev/null | grep -q '\.8000'"
need "the Authorization header is readable in it" "tcpdump -n -A -r $P 2>/dev/null | grep -q 'Authorization: Basic c2VjcmV0'"
