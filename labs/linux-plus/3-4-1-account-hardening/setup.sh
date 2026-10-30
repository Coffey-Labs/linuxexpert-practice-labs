id hardtest >/dev/null 2>&1 && refuse "user hardtest already exists; remove it (userdel -r hardtest) and start again"
id toor >/dev/null 2>&1 && refuse "an account toor already exists; remove it and start again"
is_debian && pkg_installed libpam-pwquality && state_set had-pwquality 1
# For the audit: a second UID 0 account (locked) and one with an empty
# password.
useradd -o -u 0 -g 0 -M -d /root -s /bin/bash -c "Operator" toor
passwd -l toor >/dev/null
user_add guest -c "Guest"
passwd -d guest >/dev/null
true
