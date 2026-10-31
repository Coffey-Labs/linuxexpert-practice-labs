C=/root/sshca
SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o LogLevel=ERROR -o IdentitiesOnly=yes)
# login KEY [options]: certuser logs in with KEY (and its certificate).
login() { local k=$1; shift; timeout 15 ssh "${SSHOPT[@]}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$k" "$@" certuser@localhost 'echo le-shell-ok' </dev/null 2>/dev/null | grep -q le-shell-ok; }
T=$(mktemp -d)
# A fresh key and certificate from the CA, as anyone trusting it could get.
fresh_cert() { [ -f $C/ca ] && ssh-keygen -q -t ed25519 -N '' -f $T/fresh && ssh-keygen -q -s $C/ca -I le-check -n certuser -V +5m $T/fresh.pub; }
is_debian && mkdir -p /run/sshd

task 1 "/usr/local/bin/lab-python can bind low ports for anyone"
need "/usr/local/bin/lab-python is a copy of Python, not a link" '[ -f /usr/local/bin/lab-python ] && [ ! -L /usr/local/bin/lab-python ] && /usr/local/bin/lab-python -c "import sys"'
need "it has cap_net_bind_service in its permitted and effective sets" 'getcap /usr/local/bin/lab-python | grep -Eq "cap_net_bind_service[=+]ep"'
need "nobody can bind port 999 with it" 'runuser -u nobody -- /usr/local/bin/lab-python -c "import socket; socket.socket().bind((\"127.0.0.1\", 999))"'
need "nobody still can't bind port 999 with python3" '! runuser -u nobody -- python3 -c "import socket; socket.socket().bind((\"127.0.0.1\", 999))"'

task 2 "USBGuard running with a policy for the attached devices"
need "usbguard is running and enabled" 'active usbguard && enabled usbguard'
need "/etc/usbguard/rules.conf exists, mode 600" '[ "$(stat -c %a /etc/usbguard/rules.conf)" = 600 ]'
need "every attached device is allowed" 'usbguard list-devices >$T/devs && ! grep -Eq ": (block|reject) " $T/devs'
need "the policy has a rule for each attached device" '[ "$(grep -c "^allow" /etc/usbguard/rules.conf)" -ge "$(grep -c . $T/devs)" ]'

task 3 "sshd has a host certificate from the CA for localhost"
need "$C/ca and ca.pub are an ED25519 key pair" '[ "$(ssh-keygen -y -f $C/ca 2>/dev/null | cut -d" " -f2)" = "$(cut -d" " -f2 $C/ca.pub)" ] && grep -q "^ssh-ed25519 " $C/ca.pub'
need "sshd offers a host certificate" 'timeout 10 ssh-keyscan -c -t ed25519 localhost 2>/dev/null | grep -o "ssh-ed25519-cert-v01@openssh.com .*" >$T/hostcert.pub && [ -s $T/hostcert.pub ]'
need "it's signed by the CA" 'ssh-keygen -L -f $T/hostcert.pub | grep -q "Signing CA: .*$(ssh-keygen -lf $C/ca.pub | cut -d" " -f2)"'
need "it's a host certificate for localhost" 'ssh-keygen -L -f $T/hostcert.pub >$T/l && grep -q "Type: .*host certificate" $T/l && sed -n "/Principals:/,/Critical/p" $T/l | grep -qx "[[:space:]]*localhost"'
need "it's valid now" 'v=$(ssh-keygen -L -f $T/hostcert.pub | grep "Valid:"); grep -q forever <<<"$v" || { e=$(sed -E "s/.* to //" <<<"$v"); [ "$(date -d "$e" +%s)" -gt "$(date +%s)" ]; }'

task 4 "sshd trusts the CA for user certificates; certuser logs in with one"
need "/root/sshca/user and user-cert.pub exist" '[ -f $C/user ] && [ -f $C/user-cert.pub ]'
need "user-cert.pub is signed by the CA for principal certuser" 'ssh-keygen -L -f $C/user-cert.pub >$T/u && grep -q "Signing CA: .*$(ssh-keygen -lf $C/ca.pub | cut -d" " -f2)" $T/u && sed -n "/Principals:/,/Critical/p" $T/u | grep -qx "[[:space:]]*certuser"'
need "certuser has no authorized_keys" '[ ! -s /home/certuser/.ssh/authorized_keys ]'
need "sshd -T shows trustedusercakeys" 'sshd -T 2>/dev/null | grep -q "^trustedusercakeys /"'
need "certuser logs in with a new certificate from the CA, checking the host by its certificate" 'fresh_cert && echo "@cert-authority localhost $(cat $C/ca.pub)" >$T/kh && timeout 15 ssh "${SSHOPT[@]}" -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$T/kh -i $T/fresh certuser@localhost "echo le-shell-ok" </dev/null 2>/dev/null | grep -q le-shell-ok'

task 5 "user.pub revoked in /etc/ssh/revoked.krl"
need "sshd -T shows revokedkeys /etc/ssh/revoked.krl" 'sshd -T 2>/dev/null | grep -qx "revokedkeys /etc/ssh/revoked.krl"'
need "the KRL lists user.pub as revoked" 'ssh-keygen -Q -f /etc/ssh/revoked.krl $C/user.pub | grep -q REVOKED'
need "certuser can't log in with /root/sshca/user" '[ -f $C/user ] && ! login $C/user'
need "other certificates from the CA still work" '[ -f $T/fresh-cert.pub ] || fresh_cert; login $T/fresh'

task 6 "A chroot jail in /srv/jail with bash and ls"
need "/srv/jail/bin/bash and /srv/jail/bin/ls exist" '[ -x /srv/jail/bin/bash ] && [ -x /srv/jail/bin/ls ]'
need "chroot /srv/jail /bin/bash -c \"ls /bin\" lists them" 'chroot /srv/jail /bin/bash -c "ls /bin" >$T/ls && grep -qx bash $T/ls && grep -qx ls $T/ls'
need "inside, cd /.. stays at /" '[ "$(chroot /srv/jail /bin/bash -c "cd /../..; pwd")" = / ]'
rm -rf "$T"
