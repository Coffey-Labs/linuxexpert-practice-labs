P=/root/py V=/root/py/.venv
# disk.py's exit code should match what the report itself shows.
disk_ok() {
	local out rc
	out=$(cd /tmp && "$V/bin/python3" "$P/disk.py" 2>/dev/null || python3 "$P/disk.py" 2>/dev/null); rc=$?
	grep -Eq '^/ +[0-9]+\.[0-9]%$' <<<"$out" || return 1
	if awk '{sub("%", "", $2); if ($2 + 0 >= 80) bad = 1} END {exit !bad}' <<<"$out"; then [ $rc = 1 ]; else [ $rc = 0 ]; fi
}

task 1 "~/py/.venv with pyyaml and requirements.txt"
need "~/py/.venv is a virtual environment" '[ -x "$V/bin/python3" ] && [ -f "$V/pyvenv.cfg" ]'
need "yaml imports in it" '"$V/bin/python3" -c "import yaml"'
need "~/py/requirements.txt pins PyYAML" 'grep -qi "^pyyaml==" "$P/requirements.txt"'

task 2 "~/py/disk.py reports and sets its exit code"
need "~/py/disk.py exists" '[ -f "$P/disk.py" ]'
need "it uses shutil.disk_usage" 'grep -q "disk_usage" "$P/disk.py"'
need "it prints a line for / and exits 0, or 1 when something is 80% full" disk_ok

task 3 "Interfaces and addresses from ip -j addr"
need "/root/lab-answers/3 lists lo with 127.0.0.1" 'grep -Eq "^lo +\[.*127\.0\.0\.1" /root/lab-answers/3'
need "it lists every interface" 'for i in $(ip -o link show | awk -F": " "{print \$2}" | cut -d@ -f1); do grep -q "^$i " /root/lab-answers/3 || exit 1; done'

task 4 "disk.py passes flake8"
need "flake8 is installed in ~/py/.venv" '[ -x "$V/bin/flake8" ]'
need "flake8 reports nothing for ~/py/disk.py" '"$V/bin/flake8" "$P/disk.py"'
