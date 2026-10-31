P=/root/pki
cd $P 2>/dev/null || cd /
# x FILE OPTIONS: openssl x509 -noout on a certificate.
x() { local f=$1; shift; openssl x509 -in "$f" -noout "$@" 2>/dev/null; }
# key_matches CERT KEY: the key is the certificate's.
key_matches() { [ -n "$(x "$1" -pubkey)" ] && [ "$(x "$1" -pubkey)" = "$(openssl pkey -in "$2" -pubout 2>/dev/null)" ]; }
ext() { x "$1" -ext "$2" | tail -n +2 | tr -d ' '; }

task 1 "Root CA root.crt, self-signed, ten years, CA with keyCertSign and cRLSign"
need "$P/root.crt is a certificate" 'x root.crt'
need "root.key is its key, mode 600" 'key_matches root.crt root.key && [ "$(stat -c %a root.key)" = 600 ]'
need "the subject is O = Lab, CN = Lab Root CA" 'x root.crt -subject -nameopt oneline | grep -Eq "O = Lab, CN = Lab Root CA$"'
need "it's self-signed" '[ "$(x root.crt -subject)" = "subject=$(x root.crt -issuer | cut -d= -f2-)" ] && openssl verify -CAfile root.crt root.crt'
need "basicConstraints is critical, CA:TRUE" 'x root.crt -ext basicConstraints | grep -q critical && ext root.crt basicConstraints | grep -q "^CA:TRUE"'
need "keyUsage is critical, Certificate Sign and CRL Sign" 'x root.crt -ext keyUsage | grep -q critical && ext root.crt keyUsage | grep -q CertificateSign,CRLSign'
need "it's valid for about ten years" 'x root.crt -checkend $((3640 * 86400)) >/dev/null'

task 2 "Intermediate CA int/int.crt, pathlen:0, set up for openssl ca"
need "int/int.crt is signed by the root" 'openssl verify -CAfile root.crt int/int.crt'
need "int/private/int.key is its key" 'key_matches int/int.crt int/private/int.key'
need "the subject is O = Lab, CN = Lab Issuing CA" 'x int/int.crt -subject -nameopt oneline | grep -Eq "O = Lab, CN = Lab Issuing CA$"'
need "basicConstraints is CA:TRUE, pathlen:0" 'ext int/int.crt basicConstraints | grep -qx "CA:TRUE,pathlen:0"'
need "int/ca.cnf, int/index.txt and int/serial exist" '[ -f int/ca.cnf ] && [ -f int/index.txt ] && [ -f int/serial ]'

task 3 "www.crt for www.lab.test and lab.test, issued with openssl ca"
need "www.crt is issued by the intermediate" 'x www.crt && [ "$(x www.crt -issuer | cut -d= -f2-)" = "$(x int/int.crt -subject | cut -d= -f2-)" ]'
need "www.key is its key" 'key_matches www.crt www.key'
need "its subject is O = Lab, CN = www.lab.test" 'x www.crt -subject -nameopt oneline | grep -Eq "O = Lab, CN = www.lab.test$"'
need "its names are www.lab.test and lab.test" 's=$(ext www.crt subjectAltName); grep -q "DNS:www.lab.test" <<<"$s" && grep -Eq "DNS:lab.test(,|$)" <<<"$s"'
need "it's for server authentication" 'ext www.crt extendedKeyUsage | grep -q "TLSWebServerAuthentication"'
need "it's not a CA" '! ext www.crt basicConstraints | grep -q CA:TRUE'
need "it verifies against the root with the intermediate supplied" 'openssl verify -CAfile root.crt -untrusted int/int.crt www.crt'
need "int/index.txt has its serial (it came from openssl ca)" 's=$(x www.crt -serial | cut -d= -f2); awk -F"\t" -v s="$s" "\$4 == s { f = 1 } END { exit !f }" int/index.txt'

task 4 "www.crt revoked for key compromise, CRL int.crl"
need "int/index.txt marks www.crt revoked" 's=$(x www.crt -serial | cut -d= -f2); awk -F"\t" -v s="$s" "\$4 == s && \$1 == \"R\" { f = 1 } END { exit !f }" int/index.txt'
need "int.crl is signed by the intermediate" 'openssl crl -in int.crl -CAfile int/int.crt -noout'
need "int.crl lists www.crt with reason Key Compromise" 's=$(x www.crt -serial | cut -d= -f2); openssl crl -in int.crl -noout -text | grep -A5 "Serial Number: $s" | grep -q "Key Compromise"'
need "verification with the CRL reports it revoked" 'cat int/int.crt root.crt >/tmp/le-chain.pem; openssl verify -crl_check -CAfile /tmp/le-chain.pem -CRLfile int.crl www.crt 2>&1 | grep -q "certificate revoked"'
rm -f /tmp/le-chain.pem

task 5 "www.der and www.p12"
need "www.der is www.crt in DER form" '[ -n "$(x www.crt -fingerprint)" ] && [ "$(openssl x509 -inform DER -in www.der -noout -fingerprint 2>/dev/null)" = "$(x www.crt -fingerprint)" ] && ! grep -q BEGIN www.der'
need "www.p12 opens with the password lab-only" 'openssl pkcs12 -in www.p12 -passin pass:lab-only -noout'
need "www.p12 holds www.crt and the intermediate" 'openssl pkcs12 -in www.p12 -passin pass:lab-only -nokeys 2>/dev/null >/tmp/le-p12.pem; [ "$(grep -c "BEGIN CERTIFICATE" /tmp/le-p12.pem)" = 2 ] && grep -q "Lab Issuing CA" <(openssl crl2pkcs7 -nocrl -certfile /tmp/le-p12.pem | openssl pkcs7 -print_certs -noout)'
need "www.p12 holds www.key" '[ "$(openssl pkcs12 -in www.p12 -passin pass:lab-only -nocerts -nodes 2>/dev/null | openssl pkey -pubout 2>/dev/null)" = "$(openssl pkey -in www.key -pubout 2>/dev/null)" ]'
rm -f /tmp/le-p12.pem

task 6 "CFSSL root CA cfssl-ca.pem" debian
need "cfssl-ca.pem is a CA certificate" 'ext cfssl-ca.pem basicConstraints | grep -q "^CA:TRUE"'
need "its subject has O = Lab, CN = Lab CFSSL Root" 's=$(x cfssl-ca.pem -subject -nameopt oneline); grep -q "O = Lab" <<<"$s" && grep -q "CN = Lab CFSSL Root" <<<"$s"'
need "it's self-signed" 'openssl verify -CAfile cfssl-ca.pem cfssl-ca.pem'
need "cfssl-ca-key.pem is its key" 'key_matches cfssl-ca.pem cfssl-ca-key.pem'
