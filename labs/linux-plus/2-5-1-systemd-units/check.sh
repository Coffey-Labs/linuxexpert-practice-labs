atd_nice() { ps -o ni= -p "$(systemctl show -p MainPID --value atd)" | tr -d ' '; }

task 1 "labbeat.timer runs labbeat.service every 2 minutes"
need "labbeat.service runs logger -t labbeat" 'systemctl cat labbeat.service | grep -Eq "^ExecStart=.*logger.*-t labbeat"'
need "labbeat.service is a oneshot service" '[ "$(systemctl show -p Type --value labbeat.service)" = oneshot ]'
need "labbeat.timer is enabled" enabled labbeat.timer
need "labbeat.timer is active" active labbeat.timer
need "it fires every 2 minutes" 'systemctl show -p TimersCalendar --value labbeat.timer | grep -q "\*-\*-\* \*:00/2:00"'
need "the journal has a labbeat message from it" 'journalctl -q -t labbeat --no-pager | grep -q "still here"'

task 2 "atd unmasked, running and enabled"
need "atd isn't masked" '[ "$(systemctl is-enabled atd 2>/dev/null)" != masked ]'
need "atd is running" active atd
need "atd starts at boot" enabled atd

task 3 "atd runs at nice 5 from a drop-in"
need "a drop-in for atd sets Nice=5" 'grep -qsx "Nice=5" /etc/systemd/system/atd.service.d/*.conf'
need "systemctl show atd -p Nice says 5" '[ "$(systemctl show -p Nice --value atd)" = 5 ]'
need "the running atd has nice 5" '[ "$(atd_nice)" = 5 ]'
