mkdir -p /root/filters
crlf=$(( (RANDOM % 3) + 1 ))
for i in 1 2 3; do
	printf 'Weekly report %s\nAll systems normal.\nNext check on Monday.\n' "$i" >/root/filters/report$i.txt
done
sed -i 's/$/\r/' /root/filters/report$crlf.txt
state_set crlf "report$crlf.txt"
state_set since "$(date +%s)"
