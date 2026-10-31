line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
field() { apt-cache show "$1" 2>/dev/null | awk -v f="$2:" '$1 == f { sub(/^[^:]*:[[:space:]]*/, ""); print; exit }'; }
component() { local s; s=$(field synaptic Section); case $s in */*) printf '%s' "${s%%/*}" ;; *) printf main ;; esac; }
owner=$(dpkg -S /usr/bin/lsblk 2>/dev/null | cut -d: -f1)
rdeps() { apt-cache rdepends --installed libncursesw6 2>/dev/null | sed -n '/^Reverse Depends:/,$p' | sed '1d; s/^[[:space:]|]*//; s/:.*//' | sort -u; }
listed() { grep -v '^[[:space:]]*$' /root/lab-answers/3 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/:.*//' | sort -u; }

task 1 "Owner of /usr/bin/lsblk and its file count"
need "line 1 of /root/lab-answers/1 is the package that provides /usr/bin/lsblk" '[ -n "$owner" ] && [ "$(line 1 1)" = "$owner" ]'
need "line 2 is the number of files it installs (dpkg -L)" '[ "$(line 1 2)" = "$(dpkg -L "$owner" | wc -l)" ] || [ "$(line 1 2)" = "$(dpkg -L "$owner" | while read -r f; do [ -d "$f" ] || echo; done | wc -l)" ]'

task 2 "synaptic's component, maintainer and download size"
need "line 1 of /root/lab-answers/2 is synaptic's component" '[ "$(line 2 1 | tr A-Z a-z)" = "$(component)" ]'
need "line 2 is its maintainer" 'm=$(line 2 2); [ ${#m} -ge 5 ] && field synaptic Maintainer | grep -qiF -- "$m"'
need "line 3 is its download size" 'kb=$(( ($(field synaptic Size) + 512) / 1000 )); line 2 3 | grep -Eq "(^|[^0-9])($kb|$((kb - 1))|$((kb + 1))|$(field synaptic Size))([^0-9]|$)"'

task 3 "Installed packages that depend on libncursesw6"
need "/root/lab-answers/3 lists at least three packages" '[ "$(listed | wc -l)" -ge 3 ]'
need "every package listed depends on libncursesw6 and is installed" '[ -z "$(comm -23 <(listed) <(rdeps))" ]'
