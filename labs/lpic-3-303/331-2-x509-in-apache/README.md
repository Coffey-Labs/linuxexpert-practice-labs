# LPIC-3 331.2: Certificates for encryption, signing and authentication

Apache with two HTTPS sites on one address, HSTS, a client-certificate
area and OCSP stapling, all from a small lab CA.

## Before you start

The lab points the made-up names `alpha.test` and `beta.test` at
`127.0.0.1` in `/etc/hosts`, and checks that nothing listens on port 443
yet. Keep your CA, keys and certificates in `/root/tls`, with the file names
the tasks give, and copy what Apache needs wherever you like. Ubuntu's
package is `apache2`; on the RHEL family it's `httpd` with `mod_ssl`.

## Tasks

1. In `/root/tls`, make a lab CA `ca.crt` (`/O=Lab/CN=Lab TLS CA`, key
   `ca.key`), and sign with it: `alpha.crt` and `beta.crt` (keys
   `alpha.key` and `beta.key`) for server authentication, each with its
   name (`alpha.test`, `beta.test`) as subject alternative name and the
   OCSP responder `http://127.0.0.1:8888` in its authority information
   access; and a client certificate `user.crt` (key `user.key`) for
   `/O=Lab/CN=lab-user`, for client authentication.
2. Install Apache and serve two HTTPS sites on port 443: `alpha.test`,
   whose page says `alpha site`, and `beta.test`, whose page says
   `beta site`, each with its own certificate. Allow only TLS 1.2 and 1.3,
   and send HSTS (`Strict-Transport-Security`) on both. Apache must start
   at boot.
3. On `alpha.test`, make `/admin/` (a page that says `admin area`) require
   a client certificate issued by the lab CA with organization `Lab`.
4. Run an OCSP responder for the lab CA on port 8888 with
   `openssl ocsp` and an index file that lists `alpha.crt` as valid, and
   turn on OCSP stapling, so that a client asking for the status of
   `alpha.test` gets a stapled `good` answer.

## Hints

- `openssl req -x509 ... -addext basicConstraints=critical,CA:TRUE`;
  `openssl req -new`, then `openssl x509 -req -CA ca.crt -CAkey ca.key
  -CAcreateserial -extfile` with `subjectAltName`, `extendedKeyUsage` and
  `authorityInfoAccess=OCSP;URI:...` lines.
- Two `<VirtualHost *:443>` blocks with `ServerName`, `SSLEngine on`,
  `SSLCertificateFile`, `SSLCertificateKeyFile`, `SSLProtocol` and
  `Header always set Strict-Transport-Security ...`. Ubuntu: `a2enmod ssl
  headers`, `a2ensite`. Check with `apachectl configtest` and
  `openssl s_client -connect 127.0.0.1:443 -servername beta.test`.
- `SSLCACertificateFile`, and in a `<Location /admin>`:
  `SSLVerifyClient require`, `Require expr "%{SSL_CLIENT_S_DN_O} == 'Lab'"`.
  Test with `curl --cacert ca.crt --cert user.crt --key user.key`.
- An index line is `V`, the expiry as `YYMMDDHHMMSSZ`, an empty field, the
  serial, `unknown` and the subject, separated by tabs.
  `openssl ocsp -port 8888 -index ... -CA ca.crt -rsigner ca.crt -rkey
  ca.key`, in the background. `SSLStaplingCache` (outside the virtual
  hosts) and `SSLUseStapling on`; `openssl s_client ... -status`. On the
  RHEL family, see what SELinux says when Apache asks the responder.
