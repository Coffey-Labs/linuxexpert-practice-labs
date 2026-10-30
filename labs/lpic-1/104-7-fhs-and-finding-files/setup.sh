command -v locate >/dev/null || pkg_install plocate
if [ -f /etc/updatedb.conf ]; then cp -a /etc/updatedb.conf "$LAB_STATE/updatedb.conf"; fi
mkdir -p /srv/archive
for y in 2019 2020 2021; do echo "Old report $y" >/srv/archive/le-archive-report-$y.txt; done
updatedb
