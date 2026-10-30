LINE=$(state_get bad-line)
# The kernels installed, by version.
kernels() { ls /boot/vmlinuz-* | grep -v rescue | sed 's|^/boot/vmlinuz-||'; }

task 1 "nginx's error found and fixed"
need "/root/lab-answers/1 has the file and line of the error" 'grep -q "nginx\.conf" /root/lab-answers/1 && grep -qE "(:|line )$LINE([^0-9]|$)" /root/lab-answers/1'
need "nginx -t passes" 'nginx -t'
need "nginx is running and enabled" 'active nginx && enabled nginx'

task 2 "The dummy driver loads again"
need "/root/lab-answers/2 has the file that blocked it" 'grep -q "/etc/modprobe.d/local-hardening.conf" /root/lab-answers/2'
need "no install rule stops it" '! modprobe -c | grep -qE "^install dummy "'
need "modprobe dummy works" 'modprobe dummy'

task 3 "Booted into rescue.target from the GRUB menu" self

task 4 "The kernels to fall back to"
need "/root/lab-answers/4 lists every installed kernel" '[ -s /root/lab-answers/4 ] && for k in $(kernels); do grep -qF "$k" /root/lab-answers/4 || exit 1; done'
