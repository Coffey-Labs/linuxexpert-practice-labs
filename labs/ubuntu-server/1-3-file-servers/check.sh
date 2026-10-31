# The clients /srv/projects is exported to, one per line, with options.
clients() { exportfs -s 2>/dev/null | awk '$1 == "/srv/projects" { for (i = 2; i <= NF; i++) print $i }'; }
in_fstab() { findmnt -s -n "$1" >/dev/null || [ -e "/etc/systemd/system/$(systemd-escape -p --suffix=mount "$1")" ]; }
smb() { timeout 20 ip netns exec lepeer smbclient //10.99.0.1/docs "$@" 2>&1 </dev/null; }

task 1 "/srv/projects exported to 10.99.0.1 only, mounted at /mnt/projects at boot"
need "the NFS server is running and enabled" 'active nfs-server && enabled nfs-server'
need "/srv/projects is exported" '[ -n "$(clients)" ]'
need "it's exported read-write" 'clients | grep -Eq "[(,]rw[,)]"'
need "it's exported to 10.99.0.1 only" '! clients | grep -Evq "^10\.99\.0\.1(/32)?\("'
need "the export is in /etc/exports or /etc/exports.d" 'grep -Eqs "^[[:space:]]*/srv/projects[[:space:]]" /etc/exports /etc/exports.d/*.exports'
need "/mnt/projects is an NFS 4 mount of 10.99.0.1:/srv/projects" '[ "$(findmnt -n -o FSTYPE /mnt/projects)" = nfs4 ] && findmnt -n -o SOURCE /mnt/projects | grep -Eq "^10\.99\.0\.1:/srv/projects/*$"'
need "/mnt/projects is mounted at boot (/etc/fstab)" in_fstab /mnt/projects

task 2 "pat can write to the share; root on the client can't"
need "root is squashed (no no_root_squash)" '[ -n "$(clients)" ] && ! clients | grep -q no_root_squash'
need "pat can create a file in /mnt/projects" 'f=/mnt/projects/.le-check-$$; runuser -u pat -- touch $f && [ "$(stat -c %U /srv/projects/${f##*/})" = pat ]; r=$?; rm -f /srv/projects/${f##*/}; exit $r'
need "root can't create a file in /mnt/projects" 'f=/mnt/projects/.le-check-$$; ! timeout 10 touch $f; r=$?; rm -f /srv/projects/${f##*/}; exit $r'

task 3 "Samba share docs, writable only by group docs; dana has a Samba password"
need "testparm -s shows a [docs] section for /srv/samba/docs" 'testparm -s 2>/dev/null | awk "/^\[docs\]/ { f = 1; next } /^\[/ { f = 0 } f && /path = \/srv\/samba\/docs\/?$/ { ok = 1 } END { exit !ok }"'
need "smbd is running and enabled" 'active smbd && enabled smbd'
need "dana has a Samba password" 'pdbedit -L 2>/dev/null | grep -q "^dana:"'
need "from the peer, dana can list the share" 'smb -U dana%Lab-Pass-1 -c ls | grep -q "blocks available"'
need "from the peer, dana can put a file in the share" 'n=le-check-$$; smb -U dana%Lab-Pass-1 -c "put /etc/hostname $n" >/dev/null; [ -f /srv/samba/docs/$n ]; r=$?; rm -f /srv/samba/docs/$n; exit $r'
need "from the peer, eli gets NT_STATUS_ACCESS_DENIED" 'smb -U eli%x -c ls | grep -q NT_STATUS_ACCESS_DENIED'
need "eli can't put a file in the share" 'n=le-check-$$; smb -U eli%x -c "put /etc/hostname $n" >/dev/null; [ ! -e /srv/samba/docs/$n ]; r=$?; rm -f /srv/samba/docs/$n; exit $r'
