src() { findmnt -n -o SOURCE "$1" 2>/dev/null; }
fstab_src() { findmnt --fstab -n -o SOURCE "$1" 2>/dev/null; }
on_spare() { case $(readlink -f "$(src "$1")") in /dev/loop4[01]* | /dev/dm-*) return 0 ;; esac; return 1; }

task 1 "XFS on /data, mounted at boot by UUID"
need "/data is mounted" 'findmnt -n /data'
need "it's from a spare disk" 'on_spare /data'
need "it's XFS" '[ "$(findmnt -n -o FSTYPE /data)" = xfs ]'
need "/etc/fstab mounts it on /data by UUID" '[ "$(fstab_src /data)" = "UUID=$(findmnt -n -o UUID /data)" ] || [ "$(fstab_src /data)" = "UUID=\"$(findmnt -n -o UUID /data)\"" ]'

task 2 "ext4 labeled backups on /backups, mounted at boot by label"
need "/backups is mounted" 'findmnt -n /backups'
need "it's from a spare disk" 'on_spare /backups'
need "it's ext4" '[ "$(findmnt -n -o FSTYPE /backups)" = ext4 ]'
need "its label is backups" '[ "$(findmnt -n -o LABEL /backups)" = backups ]'
need "/etc/fstab mounts it by LABEL=backups" 'fstab_src /backups | grep -Eqx "LABEL=\"?backups\"?"'

task 3 "The bad /mnt/archive line removed"
need "/etc/fstab no longer has the line for the missing UUID" '! grep -q "$(state_get bad-uuid)" /etc/fstab'
need "findmnt --verify reports no errors" 'findmnt --verify 2>&1 | grep -Eq "(^| )0 errors|no errors"'
need "findmnt --verify reports no warnings either" 'findmnt --verify 2>&1 | grep -Eq "0 warnings|no errors or warnings"'
