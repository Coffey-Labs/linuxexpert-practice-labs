mkdir -p /root/regex
awk 'BEGIN {
	srand()
	split("192.0.2.10 198.51.100.7 203.0.113.45 192.0.2.200 10.20.30.40", ip, " ")
	split("GET POST GET GET HEAD", m, " ")
	for (i = 1; i <= 60; i++) {
		a = ip[int(rand() * 5) + 1]
		printf "2026-10-%02d 10:%02d:%02d %s %s /app/v2.%d/index.html 200 %d\n", int(rand() * 28) + 1, i % 60, int(rand() * 60), a, m[int(rand() * 5) + 1], int(rand() * 9), int(rand() * 5000)
	}
}' >/root/regex/access.log
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' /root/regex/access.log | sort | uniq -c | awk '{print $1, $2}' | sort >"$LAB_STATE/counts"
