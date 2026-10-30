maker=$(dmidecode -s system-manufacturer 2>/dev/null | head -n1 | tr 'A-Z' 'a-z')
# PCI slots without a driver, without the leading domain (0000:).
nodriver=$(for d in /sys/bus/pci/devices/*; do [ -e "$d/driver" ] || echo "${d##*/}"; done | sed 's/^0000://')
# The answer's first words, without a leading domain.
slots() { awk 'NF {print tolower($1)}' /root/lab-answers/3 2>/dev/null | sed 's/^0000://'; }

task 1 "The system manufacturer"
need "/root/lab-answers/1 names the system manufacturer, $maker" '
	a=$(answer 1); [ -n "$a" ] && { [ "$a" = "$maker" ] || [[ $maker == *"$a"* ]] || [[ $a == *"$maker"* ]]; }'

task 3 "PCI devices without a driver"
if [ -z "$nodriver" ]; then
	need "/root/lab-answers/3 says none" '[ "$(answer 3)" = none ]'
else
	need "/root/lab-answers/3 lists every PCI device without a driver" '
		[ -n "$(slots)" ] && while read -r s; do slots | grep -qxF "$s" || exit 1; done <<<"$nodriver"'
	need "/root/lab-answers/3 lists only devices without a driver" '
		slots | while read -r s; do grep -qxF "$s" <<<"$nodriver" || exit 1; done'
fi
