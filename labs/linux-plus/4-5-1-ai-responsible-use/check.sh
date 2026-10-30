C=/root/cleanup.sh
# Run cleanup.sh on a scratch directory: old.tar.gz must go, the rest stay.
trial() {
	local t rc
	t=$(mktemp -d)
	touch -d '20 days ago' "$t/old.tar.gz" "$t/old.txt"
	mkdir "$t/sub" && touch -d '20 days ago' "$t/sub/deep.tar.gz"
	touch "$t/new.tar.gz"
	bash "$C" "$t" 14 >/dev/null 2>&1; rc=$?
	[ $rc = 0 ] && [ ! -e "$t/old.tar.gz" ] && [ -e "$t/new.tar.gz" ] && [ -e "$t/old.txt" ] && [ -e "$t/sub/deep.tar.gz" ]
	rc=$?; rm -rf "$t"; return $rc
}

task 1 "ShellCheck's report on ai-cleanup.sh"
need "~/ai-cleanup.sh exists" '[ -f /root/ai-cleanup.sh ] && grep -q "BACKUP_DIR" /root/ai-cleanup.sh'
need "ShellCheck is installed" 'command -v shellcheck'
need "/root/lab-answers/1 has ShellCheck's warnings (unquoted variables, cd without a check)" 'grep -q SC2086 /root/lab-answers/1 && grep -q SC2164 /root/lab-answers/1'

task 2 "A safe ~/cleanup.sh"
need "~/cleanup.sh exists and uses set -euo pipefail" 'grep -q "set -euo pipefail" "$C"'
need "it deletes only old *.tar.gz files directly in the directory" trial
need "it fails without arguments" '! bash "$C" </dev/null >/dev/null 2>&1'
need "it refuses a number of days that isn't a number" 't=$(mktemp -d); touch -d "20 days ago" "$t/old.tar.gz"; bash "$C" "$t" abc >/dev/null 2>&1; rc=$?; [ -e "$t/old.tar.gz" ]; ok=$?; rm -rf "$t"; [ $rc != 0 ] && [ $ok = 0 ]'
need "ShellCheck has nothing to say about it" 'shellcheck "$C"'
