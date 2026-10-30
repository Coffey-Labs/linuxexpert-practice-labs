line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | tr 'A-Z' 'a-z' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
family=$(. /etc/os-release; echo "${ID_LIKE:-$ID}" | tr 'A-Z' 'a-z')

task 1 "The architecture and the distribution family"
need "the first line is the architecture, $(uname -m)" '[ "$(line 1 1)" = "$(uname -m)" ]'
need "the second line is a word from ID_LIKE ($family)" 'a=$(line 1 2 | tr -d "\""); [ -n "$a" ] && grep -qw -- "$a" <<<"$family"'

task 2 "The license of bash"
need "/root/lab-answers/2 names bash's license (a version of the GPL)" 'line 2 1 | grep -Eq "gpl.*3|gnu general public license.*3"'

task 3 "A package that isn't architecture-specific"
need "/root/lab-answers/3 names an installed package" '[ -n "$(line 3 1)" ]'
if is_rhel; then
	need "that package's architecture is noarch" '[ "$(rpm -q --qf "%{ARCH}" "$(line 3 1)" 2>/dev/null)" = noarch ]'
else
	need "that package's architecture is all" '[ "$(dpkg-query -W -f "\${Architecture}" "$(line 3 1)" 2>/dev/null)" = all ]'
fi
