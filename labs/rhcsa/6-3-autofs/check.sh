# mnt_field PATH TYPE-REGEX FIELD: a field of PATH's /proc/mounts line of
# a matching type (1 source, 4 options).
mnt_field() { awk -v m="$1" -v t="^($2)\$" -v f="$3" '$2 == m && $3 ~ t {print $f; exit}' /proc/mounts; }
trigger_opts() { mnt_field "$1" autofs 4; }
use() { timeout 30 stat "$1" >/dev/null; }
use_as() { timeout 30 runuser -u "$1" -- stat "$2" >/dev/null; }
nfs_src() { mnt_field "$1" 'nfs4?' 1; }

task 1 "server:/exports/share on demand at /shares/data, 60-second timeout"
need "autofs is running" active autofs
need "autofs watches /shares with an indirect map" 'trigger_opts /shares | grep -qw indirect'
need "/shares has a 60-second timeout" 'trigger_opts /shares | tr , "\n" | grep -qx timeout=60'
need "using /shares/data shows readme.txt" use /shares/data/readme.txt
need "/shares/data is then an NFS mount of server:/exports/share" 'nfs_src /shares/data | grep -q ":/exports/share/*$"'

task 2 "Homes on demand at /rhome/USER with one map line"
need "autofs watches /rhome with an indirect map" 'trigger_opts /rhome | grep -qw indirect'
need "using /rhome/alice shows her welcome.txt" use_as alice /rhome/alice/welcome.txt
need "/rhome/alice is an NFS mount of server:/exports/homes/alice" 'nfs_src /rhome/alice | grep -q ":/exports/homes/alice/*$"'
need "the same map serves bob (/rhome/bob)" use_as bob /rhome/bob/welcome.txt
need "su - alice lands in /rhome/alice" '[ "$(timeout 30 runuser -l alice -c pwd)" = /rhome/alice ]'

task 3 "server:/exports/share at /mnt/direct with a direct map, at boot"
need "autofs starts at boot" enabled autofs
need "autofs watches /mnt/direct with a direct map" 'trigger_opts /mnt/direct | grep -qw direct'
need "cat /mnt/direct/readme.txt works" 'timeout 30 cat /mnt/direct/readme.txt'
need "/mnt/direct is then an NFS mount of server:/exports/share" 'nfs_src /mnt/direct | grep -q ":/exports/share/*$"'
