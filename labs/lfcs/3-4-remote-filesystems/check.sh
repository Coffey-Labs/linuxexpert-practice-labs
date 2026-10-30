in_fstab() { findmnt -s -n "$1" >/dev/null || [ -e "/etc/systemd/system/$(systemd-escape -p --suffix=mount "$1")" ]; }
fstab_opts() { awk -v m="$1" '!/^[[:space:]]*#/ && $2 == m {print $4}' /etc/fstab | head -n1; }
# The clients /srv/share is exported to, one per line, with their options.
share_clients() {
	exportfs -s 2>/dev/null | awk '$1 == "/srv/share" {for (i = 2; i <= NF; i++) print $i}'
}
# A file made in $1 shows up in $2.
shows_up() {
	local n=.le-lab-check-$$ rc=1
	touch "$1/$n" && [ -e "$2/$n" ] && rc=0
	rm -f "$1/$n"
	return $rc
}

task 1 "/srv/share exported to 10.99.0.0/24, mounted at /mnt/share at boot"
need "the NFS server is running" active nfs-server
need "the NFS server starts at boot" enabled nfs-server
need "/srv/share is exported" '[ -n "$(share_clients)" ]'
need "it's exported read-write" 'share_clients | grep -Eq "[(,]rw[,)]"'
need "it's exported to the lab network only (10.99.0.x)" '! share_clients | grep -vEq "^10\.99\.0\."'
need "the export is in /etc/exports or /etc/exports.d" 'grep -Eqs "^[[:space:]]*/srv/share[[:space:]]" /etc/exports /etc/exports.d/*.exports'
need "/mnt/share is an NFS mount of /srv/share" 'findmnt -n -o FSTYPE /mnt/share | grep -Eqx "nfs4?" && findmnt -n -o SOURCE /mnt/share | grep -q ":/srv/share/*$"'
need "/mnt/share is mounted at boot (/etc/fstab)" in_fstab /mnt/share
need "a file written in /mnt/share appears in /srv/share" shows_up /mnt/share /srv/share

task 2 "root's file on the share is owned by nobody"
need "/srv/share/rootfile exists" test -e /srv/share/rootfile
need "/srv/share/rootfile is owned by nobody (UID 65534)" '[ "$(stat -c %u /srv/share/rootfile)" = 65534 ]'

task 3 "Samba share projects mounted at /mnt/projects at boot"
need "/root/.smbcred is owned by root with mode 600" '[ "$(stat -c %U:%a /root/.smbcred)" = root:600 ]'
need "/mnt/projects is an SMB (cifs) mount" 'findmnt -n -o FSTYPE /mnt/projects | grep -Eqx "cifs|smb3"'
need "/mnt/projects shows /srv/samba (readme.txt)" test -e /mnt/projects/readme.txt
need "/mnt/projects is mounted at boot (/etc/fstab)" in_fstab /mnt/projects
need "/etc/fstab uses the credentials file" 'fstab_opts /mnt/projects | grep -q "cred"'
need "/etc/fstab holds no password" '! grep -Ev "^[[:space:]]*#" /etc/fstab | grep -qi "pass"'

task 4 "iSCSI target from the image, logged in at boot, XFS at /mnt/iscsi"
need "the target serves /var/lib/le-lab/iscsi/disk0.img" 'targetcli ls /backstores 2>/dev/null | grep -q /var/lib/le-lab/iscsi/disk0.img'
need "the target configuration is saved" 'grep -qs /var/lib/le-lab/iscsi/disk0.img /etc/target/saveconfig.json /etc/rtslib-fb-target/saveconfig.json'
need "the target is restored at boot" 'enabled target || enabled rtslib-fb-targetctl'
need "an iSCSI session is logged in" '[ -n "$(iscsiadm -m session 2>/dev/null)" ]'
need "the login is repeated at boot (node.startup)" 'iscsiadm -m node -o show 2>/dev/null | grep -q "node.startup = automatic"'
need "/mnt/iscsi is XFS" '[ "$(findmnt -n -o FSTYPE /mnt/iscsi)" = xfs ]'
need "/mnt/iscsi is on the iSCSI disk" 'lsblk -sno TRAN "$(findmnt -n -o SOURCE /mnt/iscsi)" | grep -qx iscsi'
need "/mnt/iscsi is mounted at boot with _netdev" 'fstab_opts /mnt/iscsi | grep -q _netdev'
