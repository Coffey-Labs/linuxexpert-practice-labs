KEY=$(state_get key)
g() { git -C /root/leaky "$@"; }

task 1 "config.env and its key gone from /root/leaky's history"
need "/root/leaky still has its other commits" 'g log --oneline | grep -q "Add app" && g log --oneline | grep -q "Document the configuration"'
need "no commit has config.env any more" '[ -z "$(g log --all --format=%H -- config.env)" ]'
need "the key is in no commit on any branch, tag or backup ref" '! g log --all -p | grep -qF "$KEY"'
need "app.py and README.md are still there" '[ -f /root/leaky/app.py ] && [ -f /root/leaky/README.md ]'

task 2 "/root/customers.csv encrypted, the original shredded"
need "/root/customers.csv.gpg is encrypted with a passphrase" 'gpg --batch --list-packets /root/customers.csv.gpg </dev/null 2>/dev/null | grep -q "symkey enc packet"'
need "/root/customers.csv is gone" '[ ! -e /root/customers.csv ]'
