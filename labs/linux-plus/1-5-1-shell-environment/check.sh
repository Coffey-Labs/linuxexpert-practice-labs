H=$(getent passwd alex | cut -d: -f6)
# The login startup file bash reads for alex: the first that exists.
P=''
for f in .bash_profile .bash_login .profile; do [ -f "$H/$f" ] && { P=$H/$f; break; }; done
# Output of a shell as alex, with no terminal.
as_alex() { runuser -u alex -- env -i HOME="$H" USER=alex LOGNAME=alex SHELL=/bin/bash PATH=/usr/local/bin:/usr/bin:/bin TERM=dumb "$@" </dev/null 2>/dev/null; }

task 1 "~/bin/hi on alex's PATH in every login shell"
need "$H/bin/hi exists and is executable" '[ -f "$H/bin/hi" ] && [ -x "$H/bin/hi" ]'
need "$H/bin/hi belongs to alex" '[ "$(stat -c %U "$H/bin/hi")" = alex ]'
need "alex's login startup file adds \$HOME/bin to PATH" '[ -n "$P" ] && grep -Eq "^[^#]*PATH=[\"]?(\\\$HOME|~|\\\$\{HOME\}|$H)/bin:" "$P"'
need "hi works in a new login shell and prints \"hi from\"" 'as_alex bash -l -c hi | grep -q "hi from .*hi"'

task 2 "echo lines in ~/.bashrc and the login startup file"
need "~/.bashrc has echo bashrc ran" 'grep -Eq "^[[:space:]]*echo [\"'"'"']?bashrc ran" "$H/.bashrc"'
need "the login startup file has echo profile ran" '[ -n "$P" ] && grep -Eq "^[[:space:]]*echo [\"'"'"']?profile ran" "$P"'
need "a login shell prints profile ran" 'as_alex bash -l -c true | grep -qx "profile ran"'
need "a non-login interactive shell prints bashrc ran but not profile ran" '
	o=$(as_alex bash -i -c true); grep -qx "bashrc ran" <<<"$o" && ! grep -qx "profile ran" <<<"$o"'

task 3 "History: !\$, !! and Ctrl+r" self
