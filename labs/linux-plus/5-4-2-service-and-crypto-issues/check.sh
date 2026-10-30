curl_ok() { curl -s --max-time 5 --cacert /etc/le-lab/tls/ca.crt --resolve lab.example.test:8443:127.0.0.1 https://lab.example.test:8443/ -o /dev/null; }
wait_local() { local i; for i in $(seq 15); do ss -Htln 'sport = :9100' | grep -q '127\.0\.0\.1:9100' && return 0; sleep 1; done; return 1; }

task 1 "metrics-exporter listens on 127.0.0.1 only"
need "/root/lab-answers/1 has its port" 'grep -qw 9100 /root/lab-answers/1'
need "metrics-exporter is running" active metrics-exporter
need "it listens on 127.0.0.1:9100" wait_local
need "it listens on no other address" '[ "$(ss -Htln "sport = :9100" | grep -vc "127\.0\.0\.1:9100")" = 0 ]'

task 2 "The server's certificate matches lab.example.test"
need "/root/lab-answers/2 has curl's exit code and the reason" 'grep -qw 60 /root/lab-answers/2 && grep -Eqi "name|subject|match|alt" /root/lab-answers/2'
need "le-lab-tls is running" active le-lab-tls
need "the certificate is signed by the lab's CA" 'openssl verify -CAfile /etc/le-lab/tls/ca.crt /etc/le-lab/tls/server.crt'
need "curl to https://lab.example.test:8443/ with the lab's CA works" 'for i in 1 2 3 4 5; do curl_ok && exit 0; sleep 1; done; exit 1'

task 3 "ssh localhost agrees on a key exchange again"
need "/root/lab-answers/3 has the file" 'grep -q "/etc/ssh/ssh_config.d/05-legacy-hosts.conf" /root/lab-answers/3'
need "ssh -G localhost doesn't insist on diffie-hellman-group1-sha1" '! ssh -G localhost 2>/dev/null | grep -qx "kexalgorithms diffie-hellman-group1-sha1"'
need "ssh localhost gets past the key exchange" '! timeout 15 ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null localhost true 2>&1 </dev/null | grep -q "no matching key exchange"'

task 4 "The broken repository found and turned off" rhel
need "/root/lab-answers/4 has its ID" 'answer 4 | grep -qw internal-tools'
need "it isn't enabled" '! dnf -q repolist --enabled 2>/dev/null | grep -qw internal-tools'
