# Does an NTP server answer at $1? Asked from the peer.
ntp_answers() {
	in_peer python3 -c '
import socket, sys
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(3)
s.sendto(b"\x23" + bytes(47), (sys.argv[1], 123))
d = s.recv(512)
sys.exit(0 if len(d) >= 48 and d[0] & 7 == 4 else 1)' "$1"
}
# Every source line chrony reads (RHEL locations).
chrony_sources() {
	cat /etc/chrony.conf /etc/chrony.d/*.conf /etc/chrony/conf.d/*.conf /etc/chrony/sources.d/*.sources 2>/dev/null |
		grep -E '^[[:space:]]*(server|pool|peer|sourcedir)[[:space:]]'
}

task 1 "Time zone Europe/Berlin"
need "the time zone is Europe/Berlin" '[ "$(timedatectl show -p Timezone --value)" = Europe/Berlin ]'
need "date shows CET or CEST" 'date +%Z | grep -Eq "^CES?T$"'

task 2 "chrony uses only time.cloudflare.com" rhel
need "chrony's configuration has time.cloudflare.com" 'chrony_sources | grep -Eq "^[[:space:]]*(server|pool)[[:space:]]+time\.cloudflare\.com"'
need "chrony's configuration has no other sources, sourcedir included" '! chrony_sources | grep -Ev "^[[:space:]]*(server|pool)[[:space:]]+time\.cloudflare\.com([[:space:]]|$)"'
need "chronyd is running and enabled" 'active chronyd && enabled chronyd'
need "chronyc sources lists only time.cloudflare.com" 'chronyc -N -c sources | cut -d, -f3 | sort -u | grep -qx time.cloudflare.com && [ "$(chronyc -N -c sources | cut -d, -f3 | sort -u | wc -l)" = 1 ]'

task 3 "systemd-timesyncd uses time.google.com" debian
need "timesyncd's configuration has NTP=time.google.com" 'conf_has /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.d "^[[:space:]]*NTP=.*time\.google\.com"'
# Once chrony has replaced systemd-timesyncd (task 5), only the
# configuration is left to grade.
if is_debian && ! pkg_installed chrony; then
	need "systemd-timesyncd is running" active systemd-timesyncd
	need "timedatectl timesync-status shows time.google.com" '[ "$(timedatectl show-timesync -p ServerName --value)" = time.google.com ]'
fi

task 4 "This VM serves NTP to 10.99.0.0/24" rhel
need "chrony.conf allows the lab network" 'grep -Eq "^[[:space:]]*allow([[:space:]]|$)" /etc/chrony.conf /etc/chrony.d/*.conf 2>/dev/null'
need "chronyd is running and enabled" 'active chronyd && enabled chronyd'
need "10.99.0.1 answers NTP requests from the peer" 'ntp_answers 10.99.0.1'

task 5 "chrony client of 10.99.0.2" debian
need "chrony is installed" pkg_installed chrony
need "chrony is running and enabled" 'active chrony && enabled chrony'
need "chrony's configuration has 10.99.0.2" 'grep -rEqs "^[[:space:]]*(server|pool)[[:space:]]+(10\.99\.0\.2|peer|peer\.lab\.example)([[:space:]]|$)" /etc/chrony'
need "chronyc sources shows 10.99.0.2 answering" 'chronyc -n -c sources | awk -F, "\$3 == \"10.99.0.2\" && \$6 != 0 {ok=1} END {exit !ok}"'
