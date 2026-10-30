UUID=$(state_get uuid)
# The fstab line for /mnt/lab, comments left out.
line() { awk '$1 !~ /^#/ && $2 == "/mnt/lab"' /etc/fstab; }
has_opt() { line | awk '{print $4}' | tr , '\n' | grep -qx "$1"; }
live_opt() { findmnt -n -o OPTIONS /mnt/lab | tr , '\n' | grep -qx "$1"; }

task 1 "/dev/loop40 in fstab by UUID at /mnt/lab with noatime,noexec,nofail"
need "/etc/fstab has one line for /mnt/lab" '[ "$(line | wc -l)" = 1 ]'
need "the line names the disk by UUID=$UUID" '[ "$(line | awk "{print \$1}" | tr -d "\"")" = "UUID=$UUID" ]'
need "the line has ext4 and the options noatime, noexec and nofail" '[ "$(line | awk "{print \$3}")" = ext4 ] && has_opt noatime && has_opt noexec && has_opt nofail'
need "/mnt/lab is mounted from /dev/loop40" '[ "$(findmnt -n -o SOURCE /mnt/lab)" = /dev/loop40 ]'
need "the mount uses noatime" 'live_opt noatime'

task 2 "true copied in; /mnt/lab remounted to allow programs"
need "/mnt/lab/true is there" '[ -f /mnt/lab/true ] && [ -x /mnt/lab/true ]'
need "/mnt/lab is mounted without noexec now" 'findmnt /mnt/lab && ! live_opt noexec'
need "/mnt/lab/true runs" /mnt/lab/true
need "/etc/fstab still says noexec" 'has_opt noexec'

task 3 "The busy mount's culprit found with lsof" self
