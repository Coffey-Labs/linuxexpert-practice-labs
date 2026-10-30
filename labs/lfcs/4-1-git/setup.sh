pkg_install git
rm -rf /srv/git/app.git /root/app
mkdir -p /srv/git
git init -q --bare -b main /srv/git/app.git

# Build the history in a scratch clone, as three different people.
work=$(mktemp -d)
git init -q -b main "$work"
git -C "$work" remote add origin /srv/git/app.git
commit() { # NAME DATE MESSAGE
	local email
	email=$(printf '%s' "${1%% *}" | tr 'A-Z' 'a-z')@example.org
	GIT_AUTHOR_NAME=$1 GIT_AUTHOR_EMAIL=$email GIT_AUTHOR_DATE="$2 10:00:00 +0000" \
		GIT_COMMITTER_NAME=$1 GIT_COMMITTER_EMAIL=$email GIT_COMMITTER_DATE="$2 10:00:00 +0000" \
		git -C "$work" commit -q -m "$3"
}

cat >"$work/app.conf" <<'X'
# Settings for the app
workers = 2

listen = 0.0.0.0:8080

# Seconds to wait for a backend
timeout = 30

# How much to log
log_level = info
X
printf '# app\n\nA small example application.\n' >"$work/README.md"
git -C "$work" add app.conf README.md
commit "Alice Smith" 2026-09-01 "Add the app configuration"

printf '2026-09-03 09:12:01 debug: starting\n2026-09-03 09:12:02 debug: 2 workers ready\n' >"$work/debug.log"
git -C "$work" add debug.log
commit "Alice Smith" 2026-09-03 "Add a debug log for troubleshooting"

sed -i 's/^timeout = 30$/timeout = 5/' "$work/app.conf"
commit_all() { git -C "$work" add -A && commit "$@"; }
commit_all "Bob Jones" 2026-09-10 "Lower the timeout"
state_set bad "$(git -C "$work" rev-parse HEAD)"

sed -i 's/^log_level = info$/log_level = warn/' "$work/app.conf"
commit_all "Alice Smith" 2026-09-15 "Log less"

printf '\nSettings are in app.conf.\n' >>"$work/README.md"
commit_all "Carol Diaz" 2026-09-20 "Document the configuration"
git -C "$work" push -q origin main
state_set main0 "$(git -C "$work" rev-parse HEAD)"

git -C "$work" switch -q -c feature/workers
sed -i 's/^workers = 2$/workers = 4/' "$work/app.conf"
commit_all "Bob Jones" 2026-09-22 "Use four workers"
git -C "$work" push -q origin feature/workers
state_set workers "$(git -C "$work" rev-parse HEAD)"

rm -rf "$work"
