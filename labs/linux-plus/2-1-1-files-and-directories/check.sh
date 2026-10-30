A=/root/lab/app/conf/app.conf R=/root/lab/copy-r/conf/app.conf C=/root/lab/copy-a/conf/app.conf
top_type() {
	file /usr/bin/* | awk -F: '{print $2}' | cut -d, -f1 | sort | uniq -c | sort -rn | head -n1 |
		sed 's/^[[:space:]]*[0-9]*[[:space:]]*//'
}

task 1 "~/lab/app built and copied with cp -r and cp -a"
need "~/lab/app has conf, logs and data" '[ -d /root/lab/app/conf ] && [ -d /root/lab/app/logs ] && [ -d /root/lab/app/data ]'
need "~/lab/app/conf/app.conf has mode 640" '[ "$(stat -c %a "$A")" = 640 ]'
need "~/lab/copy-r and ~/lab/copy-a have the same three directories" '
	for c in copy-r copy-a; do for s in conf logs data; do [ -d /root/lab/$c/$s ] || exit 1; done; done'
# app.conf in copy-a changes in task 2, so compare the logs directories.
need "the cp -a copy kept the modify times" 'a=/root/lab/app/logs c=/root/lab/copy-a/logs; [ -d "$c" ] && ! [ "$c" -nt "$a" ] && ! [ "$c" -ot "$a" ]'
need "the cp -a copy kept mode 640" '[ "$(stat -c %a "$C")" = 640 ]'
need "the cp -r copy got new modify times" '[ -f "$R" ] && [ "$R" -nt "$A" ] && [ /root/lab/copy-r/logs -nt /root/lab/app/logs ]'

task 2 "copy-a changed to 8080, unified diff saved"
need "the original still says Listen 80" 'grep -qx "Listen 80" "$A"'
need "copy-a says Listen 8080" 'grep -qx "Listen 8080" "$C"'
need "/root/lab-answers/2 is a unified diff (-Listen 80, +Listen 8080)" '
	grep -qx -- "-Listen 80" /root/lab-answers/2 && grep -qx -- "+Listen 8080" /root/lab-answers/2 && grep -q "^@@" /root/lab-answers/2'

task 3 "The most common file type in /usr/bin"
need "/root/lab-answers/3 names the most common type" '
	t=$(top_type | tr "A-Z" "a-z"); [ -n "$t" ] && tr "A-Z" "a-z" </root/lab-answers/3 | grep -qF -- "$t"'
