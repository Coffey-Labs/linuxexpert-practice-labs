# LPIC-3 331.1: X.509 certificates and public key infrastructures

A two-level CA with OpenSSL: a root, an intermediate run with `openssl ca`,
a server certificate, a revocation and a CRL, other file formats, and
CFSSL.

## Before you start

The lab makes nothing but checks that `/root/pki` doesn't exist yet. Do
everything as root, in `/root/pki`, with the file names the tasks give.
Elliptic-curve P-256 keys without a passphrase are fine throughout.

## Tasks

1. Make a root CA, `root.key` (mode 600) and the self-signed `root.crt`
   for `/O=Lab/CN=Lab Root CA`, valid for ten years, with
   `basicConstraints` critical `CA:TRUE` and `keyUsage` critical
   `keyCertSign` and `cRLSign`.
2. Make an intermediate CA, `/O=Lab/CN=Lab Issuing CA`, in `int/`: its key
   in `int/private/int.key` and its certificate `int/int.crt`, signed by the
   root and allowing no CAs below it (`pathlen:0`). Set up `int/` for
   `openssl ca` with a configuration `int/ca.cnf`, a database
   `int/index.txt` and serial files starting at 1000.
3. Request a server certificate for `/O=Lab/CN=www.lab.test` with the
   names `www.lab.test` and `lab.test` (`www.key`, `www.csr`), and issue it
   from the intermediate with `openssl ca` as `www.crt`, for server
   authentication. Check that it verifies against the root only when the
   intermediate is supplied.
4. Revoke `www.crt` with reason `keyCompromise`, publish a CRL `int.crl`
   from the intermediate, and check that verification with the CRL now
   fails.
5. Save `www.crt` in DER form as `www.der`, and bundle the key, the
   certificate and the intermediate into `www.p12` with the password
   `lab-only`.
6. Ubuntu: with CFSSL (package `golang-cfssl`), make a root CA
   `Lab CFSSL Root` (organization `Lab`) from a JSON request, written as
   `cfssl-ca.pem` and `cfssl-ca-key.pem`.

## Hints

- `openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -noenc
  -days ... -subj ... -addext ...`; `openssl x509 -noout -subject -issuer
  -ext basicConstraints,keyUsage`.
- `openssl x509 -req -CA root.crt -CAkey root.key -CAcreateserial
  -extfile`; a `[ ca ]` section with `dir`, `database`, `new_certs_dir`,
  `serial`, `crlnumber`, `certificate`, `private_key`, `policy` and
  `copy_extensions = copy`.
- `openssl req -new ... -addext subjectAltName=...`;
  `openssl ca -config int/ca.cnf -extensions ...`; `openssl verify -CAfile
  root.crt -untrusted int/int.crt www.crt`.
- `openssl ca -revoke ... -crl_reason`, `openssl ca -gencrl`;
  `openssl verify -crl_check -CAfile chain.pem -CRLfile int.crl`.
- `openssl x509 -outform DER`; `openssl pkcs12 -export -inkey -in
  -certfile -passout`.
- `cfssl gencert -initca ca.json | cfssljson -bare cfssl-ca`;
  `cfssl certinfo -cert`.
