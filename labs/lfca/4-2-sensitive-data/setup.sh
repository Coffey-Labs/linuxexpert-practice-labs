for p in /root/leaky /root/customers.csv /root/customers.csv.gpg; do
	[ ! -e "$p" ] || refuse "$p already exists; move it away first"
done
[ -e /root/.gnupg ] && state_set had-gnupg 1
[ -e /usr/local/bin/gitleaks ] && state_set had-gitleaks-bin 1
# Packages the tasks install: reset removes the ones that weren't here.
for p in git git-filter-repo $(pick epel-release gitleaks); do
	pkg_installed "$p" || echo "$p" >>"$LAB_STATE/not-installed"
done
pkg_installed git || pkg_install git

# The repository with a leaked key, and commits after it.
KEY=ghp_$(head -c 200 /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 36)
state_set key "$KEY"
mkdir -p /root/leaky
cd /root/leaky
g() { git -c user.name="Sam Developer" -c user.email=sam@example.test -c init.defaultBranch=main "$@" >/dev/null; }
g init -q
echo '# Shop backend' >README.md
g add README.md && g commit -q -m "Add readme"
printf 'import os\nprint("shop running")\n' >app.py
g add app.py && g commit -q -m "Add app"
printf 'DB_HOST=db.internal\nGITHUB_TOKEN=%s\n' "$KEY" >config.env
g add config.env && g commit -q -m "Add configuration"
printf 'import os\ntoken = os.environ["GITHUB_TOKEN"]\nprint("shop running")\n' >app.py
g commit -q -am "Read the token from the environment"
echo 'Run app.py with the variables from config.env.' >>README.md
g commit -q -am "Document the configuration"
cd /

printf 'name,email\nAda Lovelace,ada@example.test\nAlan Turing,alan@example.test\n' >/root/customers.csv
chmod 600 /root/customers.csv
