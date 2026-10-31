line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr A-Z a-z; }
component() { local s; s=$(apt-cache show "$1" 2>/dev/null | awk '$1 == "Section:" {print $2; exit}'); [ -n "$s" ] || return; case $s in */*) printf '%s' "${s%%/*}" ;; *) printf main ;; esac; }
gpl_count() { grep -l '^License: .*GPL' /usr/share/doc/*/copyright 2>/dev/null | wc -l; }

task 1 "Licenses of bash and openssl"
need "line 1 of /root/lab-answers/1 is bash's license (GPL version 3 or later)" 'line 1 1 | grep -Eq "gpl.?(v)?3"'
need "line 2 is openssl's license (Apache 2.0)" 'line 1 2 | grep -Eq "apache"'
need "line 3 is the package that could be built into a closed-source product" '[ "$(line 1 3)" = openssl ]'

task 2 "Components of ubuntu-drivers-common and nvidia-driver-535"
need "line 1 of /root/lab-answers/2 is ubuntu-drivers-common's component" 'c=$(component ubuntu-drivers-common); [ -n "$c" ] && [ "$(line 2 1)" = "$c" ]'
need "line 2 is nvidia-driver-535's component" 'c=$(component nvidia-driver-535); [ -n "$c" ] && [ "$(line 2 2)" = "$c" ]'

task 3 "Number of installed packages under a GPL license"
need "/root/lab-answers/3 has the count (within 10%)" 'a=$(line 3 1); n=$(gpl_count); [[ $a =~ ^[0-9]+$ ]] && [ $((a * 10)) -ge $((n * 9)) ] && [ $((a * 10)) -le $((n * 11)) ]'
