running() { systemctl list-units --type=service --state=running --no-legend | wc -l; }
disabled() { systemctl list-unit-files --type=service --state=disabled --no-legend | awk '{ print $1 }'; }
# How many of the disabled services the answer leaves out.
missing() { disabled | grep -vxFf <(tr -s ' \t' '\n' </root/lab-answers/1-disabled) | wc -l; }

task 1 "Running services counted, disabled services listed"
need "/root/lab-answers/1 holds a number" 'answer 1 | grep -Eqx "[0-9]+"'
need "the number matches the running services (give or take 3)" 'a=$(answer 1); r=$(running); [ "$a" -ge $((r - 3)) ] && [ "$a" -le $((r + 3)) ]'
need "/root/lab-answers/1-disabled includes debug-shell.service" 'grep -qw "debug-shell\(\.service\)\?" /root/lab-answers/1-disabled'
need "/root/lab-answers/1-disabled lists the disabled services" '[ "$(missing)" -le 2 ]'

task 2 "The lab's failed service found and removed; nothing failed"
need "/root/lab-answers/2 names inventory-sync" 'grep -q "inventory-sync" /root/lab-answers/2'
need "/root/lab-answers/2 gives its status code, 203/EXEC" 'grep -Eq "203" /root/lab-answers/2'
need "inventory-sync.service is deleted" '[ ! -e /etc/systemd/system/inventory-sync.service ] && ! systemctl cat inventory-sync.service'
need "systemctl --failed lists 0 loaded units" '[ -z "$(systemctl --failed --no-legend)" ]'

task 3 "apport masked, the masked units listed, apport unmasked"
need "/root/lab-answers/3 lists apport.service among the masked units" 'grep -q "^apport\.service.*masked" /root/lab-answers/3'
need "/root/lab-answers/3 lists the other masked units too" '[ "$(grep -c "masked" /root/lab-answers/3)" -ge 2 ]'
need "apport isn't masked now" '[ "$(systemctl is-enabled apport 2>/dev/null)" != masked ]'
need "systemctl is-enabled apport prints enabled" '[ "$(systemctl is-enabled apport 2>/dev/null)" = enabled ]'
