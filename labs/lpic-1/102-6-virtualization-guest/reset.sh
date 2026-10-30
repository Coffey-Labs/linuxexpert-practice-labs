h=$(state_get hostname)
[ -n "$h" ] && hostnamectl set-hostname "$h"
true
