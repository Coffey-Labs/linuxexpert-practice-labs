D=/root/tls
subj() { openssl x509 -in "$1" -noout -subject -nameopt RFC2253 | sed 's/^subject=//'; }
issuer() { openssl x509 -in "$1" -noout -issuer -nameopt RFC2253 | sed 's/^issuer=//'; }
self_signed() { [ "$(subj "$1")" = "$(issuer "$1")" ]; }
days_valid() {
	local nb na
	nb=$(date -d "$(openssl x509 -in "$1" -noout -startdate | cut -d= -f2)" +%s)
	na=$(date -d "$(openssl x509 -in "$1" -noout -enddate | cut -d= -f2)" +%s)
	echo $(((na - nb) / 86400))
}
key_matches() { [ "$(openssl x509 -in "$1" -noout -pubkey | sha256sum)" = "$(openssl pkey -in "$2" -pubout | sha256sum)" ]; }
# The certificate nginx sends for web1.example.org, in PEM.
served() {
	timeout 10 openssl s_client -connect 127.0.0.1:443 -servername web1.example.org </dev/null 2>/dev/null |
		openssl x509 2>/dev/null
}
fp() { openssl x509 -noout -fingerprint -sha256 2>/dev/null; }
redirects() {
	local r
	r=$(curl -s -o /dev/null --max-time 5 -w '%{http_code} %{redirect_url}' http://web1.example.org/)
	case $r in 30[1278]" https://web1.example.org"*) return 0 ;; esac
	return 1
}
signed_by_ca() { openssl verify -no-CApath -no-CAstore -CAfile "$D/ca.crt" "$1" && ! self_signed "$1"; }
served_signed() {
	local f
	f=$(mktemp); served >"$f"
	[ -s "$f" ] && signed_by_ca "$f"; local rc=$?
	rm -f "$f"; return $rc
}

# The date in answer 5 is within 36 hours of the site's notAfter (or, if
# the site can't be reached now, a date in the coming 400 days).
expiry_ok() {
	local a ad real rd now
	a=$(head -n1 /root/lab-answers/5 2>/dev/null | sed 's/^.*notAfter=//')
	[ -n "$a" ] && ad=$(date -u -d "$a" +%s 2>/dev/null) || return 1
	real=$(timeout 15 openssl s_client -connect www.kernel.org:443 -servername www.kernel.org </dev/null 2>/dev/null |
		openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
	if [ -n "$real" ]; then
		rd=$(date -u -d "$real" +%s)
		[ $((ad > rd ? ad - rd : rd - ad)) -le 129600 ]
	else
		now=$(date +%s)
		[ "$ad" -gt "$now" ] && [ "$ad" -lt $((now + 400 * 86400)) ]
	fi
}

task 1 "Self-signed certificate for web1.example.org"
need "/root/tls/web1-self.crt and /root/tls/web1-self.key exist" '[ -f $D/web1-self.crt ] && [ -f $D/web1-self.key ]'
need "the key is 3072-bit RSA" 'openssl x509 -in $D/web1-self.crt -noout -text | grep -q "Public-Key: (3072 bit)" && openssl x509 -in $D/web1-self.crt -noout -text | grep -q rsaEncryption'
need "the key matches the certificate" 'key_matches $D/web1-self.crt $D/web1-self.key'
need "the certificate is self-signed" 'self_signed $D/web1-self.crt'
need "it is valid for 365 days" '[ "$(days_valid $D/web1-self.crt)" = 365 ]'
need "its subject alternative names include web1.example.org and www.example.org" 'openssl x509 -in $D/web1-self.crt -noout -ext subjectAltName | grep -q "DNS:web1.example.org" && openssl x509 -in $D/web1-self.crt -noout -ext subjectAltName | grep -q "DNS:www.example.org"'

task 2 "nginx serves HTTPS for web1.example.org, HTTP redirects"
need "nginx is running and starts at boot" 'active nginx && enabled nginx'
need "nginx sends a certificate for web1.example.org on port 443" 'served | openssl x509 -noout -ext subjectAltName | grep -q DNS:web1.example.org'
need "http://web1.example.org/ redirects to https://web1.example.org/" redirects

task 3 "Private CA; nginx uses a certificate it signed"
need "/root/tls/ca.crt is a self-signed CA certificate" '[ -f $D/ca.crt ] && self_signed $D/ca.crt'
need "/root/tls/web1.crt is signed by ca.crt" 'signed_by_ca $D/web1.crt'
need "web1.crt is for web1.example.org" 'openssl x509 -in $D/web1.crt -noout -ext subjectAltName | grep -q DNS:web1.example.org'
need "nginx sends web1.crt" '[ -n "$(served | fp)" ] && [ "$(served | fp)" = "$(fp <$D/web1.crt)" ]'

task 4 "The system trusts the CA"
need "nginx sends a certificate signed by the CA (task 3)" served_signed
need "curl https://web1.example.org/ works without -k" 'curl -s -o /dev/null --max-time 5 https://web1.example.org/'

task 5 "Expiry date of www.kernel.org's certificate"
need "/root/lab-answers/5 has the date the certificate of www.kernel.org expires" expiry_ok
