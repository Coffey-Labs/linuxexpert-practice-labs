H=$(state_get history)
# Transactions made since the lab started.
new_tx() { dnf -q history list 2>/dev/null | awk -v h="${H:-0}" '$1 ~ /^[0-9]+$/ && $1 > h {print $1}'; }

task 1 "mariadb installed from a downloaded file, with its dependencies"
need "mariadb is installed" 'rpm -q mariadb'
need "mariadb came from a file (@commandline)" 'dnf -q info --installed mariadb 2>/dev/null | grep -Eq "^From repo[[:space:]]*:[[:space:]]*@?commandline"'
need "its dependencies came along (mariadb-common is installed)" 'rpm -q mariadb-common'

task 2 "All available updates applied"
need "a transaction since the lab started upgraded packages" 'for t in $(new_tx); do dnf -q history info "$t" 2>/dev/null | grep -Eq "^[[:space:]]+Upgrade(d)?[[:space:]]" && exit 0; done; exit 1'
need "dnf check-update lists nothing (exit status 0)" 'dnf -q check-update'
