T=/root/tls
cd $T 2>/dev/null || cd /
x() { local f=$1; shift; openssl x509 -in "$f" -noout "$@" 2>/dev/null; }
ext() { x "$1" -ext "$2" | tail -n +2 | tr -d ' '; }
key_matches() { [ -n "$(x "$1" -pubkey)" ] && [ "$(x "$1" -pubkey)" = "$(openssl pkey -in "$2" -pubout 2>/dev/null)" ]; }
# sclient NAME [options]: a handshake with the server for NAME on 127.0.0.1:443.
sclient() { local n=$1; shift; timeout 10 openssl s_client -connect 127.0.0.1:443 -servername "$n" -CAfile $T/ca.crt "$@" </dev/null 2>&1; }
CURL=(curl -s --max-time 5 --cacert $T/ca.crt)
SVC=$(pick httpd apache2)

task 1 "Lab CA, alpha.crt and beta.crt with OCSP URL, client certificate user.crt"
need "ca.crt is a CA for O = Lab, CN = Lab TLS CA" 'x ca.crt -subject -nameopt oneline | grep -Eq "O = Lab, CN = Lab TLS CA$" && ext ca.crt basicConstraints | grep -q "^CA:TRUE"'
need "ca.key is its key" 'key_matches ca.crt ca.key'
for s in alpha beta; do
	need "$s.crt is signed by the CA, with key $s.key" "openssl verify -CAfile ca.crt $s.crt && key_matches $s.crt $s.key"
	need "$s.crt names $s.test" "ext $s.crt subjectAltName | grep -q 'DNS:$s.test'"
	need "$s.crt is for server authentication" "ext $s.crt extendedKeyUsage | grep -q TLSWebServerAuthentication"
	need "$s.crt names the OCSP responder http://127.0.0.1:8888" "x $s.crt -ocsp_uri | grep -Eq '^http://127\.0\.0\.1:8888/?$'"
done
need "user.crt is signed by the CA, with key user.key" 'openssl verify -CAfile ca.crt user.crt && key_matches user.crt user.key'
need "user.crt is for O = Lab, CN = lab-user" 'x user.crt -subject -nameopt oneline | grep -Eq "O = Lab, CN = lab-user$"'
need "user.crt is for client authentication" 'ext user.crt extendedKeyUsage | grep -q TLSWebClientAuthentication'

task 2 "Two HTTPS sites on 443, by name, TLS 1.2+, HSTS"
need "Apache is running and enabled" "active $SVC && enabled $SVC"
need "something listens on port 443" 'for i in $(seq 15); do listening 443 tcp && exit 0; sleep 1; done; exit 1'
for s in alpha beta; do
	need "$s.test gets $s.crt, which verifies" "sclient $s.test >/tmp/le-s.out; grep -q 'Verify return code: 0' /tmp/le-s.out && grep -Eq '^subject=.*CN ?= ?$s.test' /tmp/le-s.out"
	need "https://$s.test/ says $s site" "\"\${CURL[@]}\" https://$s.test/ | grep -q '$s site'"
	need "https://$s.test/ sends Strict-Transport-Security" "\"\${CURL[@]}\" -I https://$s.test/ | grep -qi '^strict-transport-security:'"
done
need "TLS 1.3 works" 'sclient alpha.test -tls1_3 | grep -q "TLSv1.3"'
need "TLS 1.1 is refused" '! sclient alpha.test -tls1_1 -cipher DEFAULT@SECLEVEL=0 | grep -q "^New, TLSv1"'
rm -f /tmp/le-s.out

task 3 "alpha.test/admin/ needs a lab client certificate"
need "without a client certificate, /admin/ is refused" '! "${CURL[@]}" https://alpha.test/admin/ | grep -q "admin area"'
need "with user.crt, /admin/ says admin area" '"${CURL[@]}" --cert user.crt --key user.key https://alpha.test/admin/ | grep -q "admin area"'
need "the rest of alpha.test needs no certificate" '"${CURL[@]}" https://alpha.test/ | grep -q "alpha site"'

task 4 "OCSP responder on port 8888, stapled good answer"
need "an OCSP responder listens on port 8888" 'listening 8888 tcp'
need "it says alpha.crt is good" 'openssl ocsp -issuer ca.crt -cert alpha.crt -url http://127.0.0.1:8888 -CAfile ca.crt -timeout 5 2>/dev/null | grep -q "alpha.crt: good"'
need "alpha.test staples a good OCSP answer" 'for i in 1 2 3; do sclient alpha.test -status >/tmp/le-s.out; grep -q "OCSP Response Status: successful" /tmp/le-s.out && grep -q "Cert Status: good" /tmp/le-s.out && exit 0; sleep 2; done; exit 1'
rm -f /tmp/le-s.out
