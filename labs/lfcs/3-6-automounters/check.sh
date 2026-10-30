# mnt_field PATH TYPE-REGEX FIELD: a field of PATH's /proc/mounts line of
# a matching type (1 source, 4 options).
mnt_field() { awk -v m="$1" -v t="^($2)\$" -v f="$3" '$2 == m && $3 ~ t {print $f; exit}' /proc/mounts; }
trigger_opts() { mnt_field "$1" autofs 4; }
# use PATH: touch it, so an automounter mounts it.
use() { timeout 30 stat "$1" >/dev/null; }
# use_as USER PATH: the same as USER (root is squashed on the share).
use_as() { timeout 30 runuser -u "$1" -- stat "$2" >/dev/null; }
nfs_src() { mnt_field "$1" 'nfs4?' 1; }

task 1 "autofs direct map: nfs1:/srv/share at /mnt/share"
need "autofs is running" active autofs
need "autofs starts at boot" enabled autofs
need "autofs watches /mnt/share with a direct map" 'trigger_opts /mnt/share | grep -qw direct'
need "using /mnt/share shows hello.txt" use /mnt/share/hello.txt
need "/mnt/share is then an NFS mount of nfs1:/srv/share" 'nfs_src /mnt/share | grep -q ":/srv/share/*$"'

task 2 "Homes under /home/remote with a wildcard map; alice lives there"
need "autofs watches /home/remote with an indirect map" 'trigger_opts /home/remote | grep -qw indirect'
need "using /home/remote/alice shows her welcome.txt" use_as alice /home/remote/alice/welcome.txt
need "/home/remote/alice is an NFS mount of nfs1:/export/home/alice" 'nfs_src /home/remote/alice | grep -q ":/export/home/alice/*$"'
need "the same map serves bob (/home/remote/bob)" use_as bob /home/remote/bob/welcome.txt
need "alice's home directory is /home/remote/alice" '[ "$(getent passwd alice | cut -d: -f6)" = /home/remote/alice ]'
need "logging in as alice lands in /home/remote/alice" '[ "$(timeout 30 runuser -l alice -c pwd)" = /home/remote/alice ]'

task 3 "autofs unmounts idle shares after 30 seconds"
need "/mnt/share has a 30-second timeout" 'trigger_opts /mnt/share | tr , "\n" | grep -qx timeout=30'
need "/home/remote has a 30-second timeout" 'trigger_opts /home/remote | tr , "\n" | grep -qx timeout=30'

task 4 "/dev/loop40 mounts at /data on first use (systemd)"
need "/etc/fstab has /data with x-systemd.automount" 'findmnt -s -n -o OPTIONS /data | tr , "\n" | grep -qx x-systemd.automount'
need "systemd's automount for /data is active" active data.automount
need "using /data mounts /dev/loop40 there" 'use /data/lost+found && [ "$(mnt_field /data "ext[234]" 1)" = /dev/loop40 ]'
