findmnt /data >/dev/null && refuse "something is mounted at /data; unmount it first"
[ -d /data ] && state_set had-data 1
if pkg_installed nginx; then
	state_set had-nginx 1
	enabled nginx && state_set nginx-was-enabled 1
	active nginx && state_set nginx-was-active 1
	grep -Eq '^[[:space:]]*worker_processes[[:space:]]+[^;]+;' /etc/nginx/nginx.conf ||
		refuse "/etc/nginx/nginx.conf has no worker_processes line for the lab's typo; reinstall nginx's default configuration first"
else
	pkg_install nginx
fi
pkg_installed stress-ng || state_set no-stress-ng 1

# Task 1: a nearly full /data.
dev=$(disk_add 0 1G)
mkfs.ext4 -q "$dev"
mkdir -p /data
mount "$dev" /data
mkdir -p /data/reports/2026 /data/home/sam/.cache/old /data/www
for m in 01 02 03 04 05 06 07 08 09 10; do seq 1 2000 >/data/reports/2026/sales-$m.csv; done
echo '<h1>Intranet</h1>' >/data/www/index.html
fallocate -l 820M /data/home/sam/.cache/old/render-tmp.bin
state_set big /data/home/sam/.cache/old/render-tmp.bin

# Task 2: a typo in nginx.conf.
cp -a /etc/nginx/nginx.conf "$LAB_STATE/nginx.conf"
sed -i -E '0,/^([[:space:]]*worker_processes[[:space:]]+[^;]+);/s//\1/' /etc/nginx/nginx.conf
nginx -t 2>/dev/null && die "the typo didn't take; nginx -t still passes"
systemctl enable --quiet nginx
systemctl restart nginx 2>/dev/null || true
