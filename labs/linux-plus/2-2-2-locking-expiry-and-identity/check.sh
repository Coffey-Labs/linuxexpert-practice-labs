sh_field() { getent shadow agetest | cut -d: -f"$1"; }

task 1 "agetest with a home directory and a password"
need "user agetest exists" id agetest
need "agetest has a home directory" '[ -d "$(getent passwd agetest | cut -d: -f6)" ]'
need "agetest has a password set" 'h=$(sh_field 2); h=${h#!}; [ -n "$h" ] && [ "${h#\*}" = "$h" ]'

task 2 "agetest must change the password at the next login"
need "the last password change is day 0" '[ "$(sh_field 3)" = 0 ]'

task 3 "Password unlocked again, account expired"
need "agetest's password isn't locked" '[ -n "$(sh_field 2)" ] && [ "$(sh_field 2 | cut -c1)" != "!" ]'
need "the account expires on day 0" '[ "$(sh_field 8)" = 0 ]'
