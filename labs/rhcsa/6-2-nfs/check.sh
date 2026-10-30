fstab_opts() { findmnt -s -n -o OPTIONS "$1" 2>/dev/null; }
from_server() { grep -Eq "^(server(\.lab\.example)?|10\.99\.0\.2):/exports/share/*$"; }

task 1 "server's exports listed in /root/lab-answers/1"
need "/root/lab-answers/1 lists /exports/share" 'grep -qs "^/exports/share[[:space:]]" /root/lab-answers/1'
need "/root/lab-answers/1 lists /exports/homes" 'grep -qs "^/exports/homes[[:space:]]" /root/lab-answers/1'

task 2 "The share mounted by hand and its secret word read"
need "/root/lab-answers/2 holds the secret word from readme.txt" '[ "$(answer 2)" = "$(state_get word)" ]'

task 3 "server:/exports/share mounted at /mnt/nfs at every boot"
need "/mnt/nfs is an NFS mount" 'findmnt -n -o FSTYPE /mnt/nfs | grep -Eqx "nfs4?"'
need "/mnt/nfs is mounted from server:/exports/share" 'findmnt -n -o SOURCE /mnt/nfs | from_server'
need "/mnt/nfs shows readme.txt" 'timeout 10 test -f /mnt/nfs/readme.txt'
need "/etc/fstab mounts server:/exports/share at /mnt/nfs" 'findmnt -s -n -o SOURCE /mnt/nfs | from_server'
need "the fstab line has _netdev" 'fstab_opts /mnt/nfs | tr , "\n" | grep -qx _netdev'
