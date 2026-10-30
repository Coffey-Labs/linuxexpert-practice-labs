# net_line N NET BCAST FIRST LAST: line N of answer 1 has these four, in
# order (a /prefix after the network is fine).
net_line() {
	local l
	l=$(sed -n "$1p" /root/lab-answers/1 2>/dev/null | sed 's#/[0-9]*##g; s/[,;]/ /g' | xargs)
	[ "$l" = "$2 $3 $4 $5" ]
}
# The ports in the chapter's table.
TABLE=" 20 21 22 23 25 53 80 110 123 139 143 161 162 389 443 465 514 636 993 995 "
# ports_ok: at least ten distinct table ports, each with a name or alias
# /etc/services gives it.
ports_ok() {
	local port name n=0 seen=" "
	while read -r port name _; do
		[[ $port =~ ^[0-9]+$ ]] || continue
		[[ $TABLE == *" $port "* ]] || continue
		[[ $seen == *" $port "* ]] && continue
		awk -v p="$port" -v n="$name" '$1 !~ /^#/ && $2 ~ "^"p"/" { for (i = 1; i <= NF; i++) { if ($i ~ /^#/) break; if (i != 2 && tolower($i) == tolower(n)) f = 1 } } END { exit !f }' /etc/services || return 1
		seen+="$port " n=$((n + 1))
	done </root/lab-answers/2
	[ "$n" -ge 10 ]
}
v6() { sed -n "$1p" /root/lab-answers/3 2>/dev/null | tr A-Z a-z | xargs; }

task 1 "Network, broadcast, first and last host of three networks"
need "line 1: 10.1.2.0 10.1.3.255 10.1.2.1 10.1.3.254" 'net_line 1 10.1.2.0 10.1.3.255 10.1.2.1 10.1.3.254'
need "line 2 (172.16.40.200/27) is right" 'net_line 2 172.16.40.192 172.16.40.223 172.16.40.193 172.16.40.222'
need "line 3 (192.168.5.5/30) is right" 'net_line 3 192.168.5.4 192.168.5.7 192.168.5.5 192.168.5.6'

task 2 "Ten ports from the chapter's table and their names"
need "/root/lab-answers/2 has ten ports from the table, each with its name in /etc/services" ports_ok

task 3 "IPv6 addresses shortened and expanded"
need "line 1 is fe80::204:61ff:fe9d:f156" '[ "$(v6 1)" = fe80::204:61ff:fe9d:f156 ]'
need "line 2 is 2001:0db8:000a:0000:0000:0000:0000:0001" '[ "$(v6 2)" = 2001:0db8:000a:0000:0000:0000:0000:0001 ]'
