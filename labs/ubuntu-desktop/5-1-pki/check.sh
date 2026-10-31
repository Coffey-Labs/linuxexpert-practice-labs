P=/root/pki
line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
site=$(timeout 15 openssl s_client -connect ubuntu.com:443 -servername ubuntu.com </dev/null 2>/dev/null | openssl x509 -noout -issuer -enddate 2>/dev/null)
issuer_ok() {
	local a; a=$(line 1 1 | tr A-Z a-z); [ ${#a} -ge 2 ] || return 1
	grep '^issuer=' <<<"$site" | sed 's/^issuer=//' | tr ',' '\n' | sed -n 's/^[[:space:]]*\(O\|CN\)[[:space:]]*=[[:space:]]*//p' |
		tr A-Z a-z | while read -r v; do [ "$v" = "$a" ] || [[ $a == *"$v"* ]] && echo ok; done | grep -q ok
}
expiry_ok() {
	local e a; e=$(grep '^notAfter=' <<<"$site" | cut -d= -f2); a=$(line 1 2)
	[ -n "$e" ] && [ -n "$a" ] && [ "$(date -u -d "$a" +%F 2>/dev/null)" = "$(date -u -d "$e" +%F)" ]
}
fp() { openssl x509 -noout -fingerprint -sha256 -in "$1" 2>/dev/null; }
was_trusted() { [ -f "$P/ca.crt" ] && grep -qxF "$(fp "$P/ca.crt")" "$LAB_STATE/ca-added" 2>/dev/null; }
trusted_now() { openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt -no-CApath -no-CAstore "$P/server.crt" >/dev/null 2>&1; }

# A server of the check's own with your certificate and key, since
# yours on 4433 doesn't survive a reboot.
port=''
if [ -f "$P/server.crt" ] && [ -f "$P/server.key" ]; then
	for p in $(seq 44330 44339); do listening "$p" || { port=$p; break; }; done
	if [ -n "$port" ]; then
		openssl s_server -accept "$port" -cert "$P/server.crt" -key "$P/server.key" -www -quiet </dev/null >/dev/null 2>&1 &
		srv=$!
		for i in $(seq 25); do listening "$port" && break; sleep 0.2; done
	fi
fi
curl_ok() { [ -n "$port" ] && curl -s -o /dev/null --max-time 10 "$@" "https://localhost:$port/"; }
curl_rc() { [ -n "$port" ] || { echo none; return; }; curl -s -o /dev/null --max-time 10 "https://localhost:$port/"; echo $?; }

task 1 "Issuer and expiry date of ubuntu.com's certificate"
need "the VM can reach ubuntu.com:443" '[ -n "$site" ]'
need "line 1 of /root/lab-answers/1 is the issuer's organization or CN" issuer_ok
need "line 2 is the expiry date" expiry_ok

task 2 "Your CA and a localhost certificate, trusted system-wide"
need "/root/pki has ca.crt, server.crt and server.key" '[ -f $P/ca.crt ] && [ -f $P/server.crt ] && [ -f $P/server.key ]'
need "ca.crt is a CA certificate (CA:TRUE)" 'openssl x509 -in $P/ca.crt -noout -ext basicConstraints | grep -q "CA:TRUE"'
need "server.crt is valid for localhost" 'openssl x509 -in $P/server.crt -noout -checkhost localhost | grep -q "does match"'
need "server.crt is signed by ca.crt" 'openssl verify -CAfile $P/ca.crt -no-CApath -no-CAstore $P/server.crt'
need "a server with server.crt and server.key works for curl --cacert ca.crt" 'curl_ok --cacert $P/ca.crt'
need "update-ca-certificates added ca.crt to the system trust store" was_trusted

task 3 "Your CA out of the trust store again"
need "your CA was in the trust store first (task 2)" was_trusted
need "the system trust store no longer has your CA" '! trusted_now'
need "curl to a server with your certificate fails with error 60" '[ "$(curl_rc)" = 60 ]'

[ -n "${srv:-}" ] && kill "$srv" 2>/dev/null
true
