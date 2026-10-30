command -v man >/dev/null || pkg_install man-db
command -v crontab >/dev/null || pkg_install cronie/cron
mandb -q >/dev/null 2>&1 || true
