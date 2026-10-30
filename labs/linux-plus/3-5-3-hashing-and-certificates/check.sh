D=/root/pki
x509() { openssl x509 -noout "$@" 2>/dev/null; }

task 1 "f.sha256 catches the change to f.txt"
need "/root/f.sha256 has the checksum of version 1 for f.txt" 'grep -Eq "^$(printf "version 1\n" | sha256sum | cut -d" " -f1)[[:space:]]+\*?f\.txt$" /root/f.sha256'
need "/root/f.txt now says version 2" 'grep -qx "version 2" /root/f.txt'
need "sha256sum -c reports the change" 'cd /root && ! sha256sum -c f.sha256'

task 2 "A private CA and a certificate for lab.example.test signed by it"
need "$D/ca.crt is a CA certificate with subject CN = Lab CA" 'x509 -in $D/ca.crt -subject | grep -q "CN *= *Lab CA" && x509 -in $D/ca.crt -ext basicConstraints | grep -q "CA:TRUE"'
need "$D/ca.key is its key" '[ "$(x509 -in $D/ca.crt -pubkey | sha256sum)" = "$(openssl pkey -in $D/ca.key -pubout 2>/dev/null | sha256sum)" ]'
need "$D/www.crt names lab.example.test in its subject alternative names" 'x509 -in $D/www.crt -ext subjectAltName | grep -q "DNS:lab\.example\.test"'
need "$D/www.key is its key" '[ "$(x509 -in $D/www.crt -pubkey | sha256sum)" = "$(openssl pkey -in $D/www.key -pubout 2>/dev/null | sha256sum)" ]'
need "openssl verify -CAfile ca.crt www.crt succeeds" 'openssl verify -CAfile $D/ca.crt $D/www.crt'

task 3 "The CA trusted system-wide"
need "openssl verify www.crt succeeds without -CAfile" 'openssl verify $D/www.crt'
