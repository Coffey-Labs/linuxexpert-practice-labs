nodes_wait 60 || true
A=/home/greg/ansible
# inproject SUM: some file in greg's project has this SHA-256.
inproject() { find $A -path $A/fetched -prune -o -type f -size -1024k -print0 2>/dev/null | xargs -0r sha256sum | grep -q "^$1 "; }
sum() { in_node "$1" sha256sum /etc/issue.net | cut -d' ' -f1; }

task 1 "/etc/issue.net from a project file, root, 0644, with backups"
for n in $(nodes_names); do
	need "/etc/issue.net on $n is owned by root:root with mode 644" "[ \"\$(in_node $n stat -c '%U:%G %a' /etc/issue.net)\" = 'root:root 644' ]"
	need "/etc/issue.net on $n is no longer the old banner" "! in_node $n grep -q '^Old banner' /etc/issue.net"
	need "/etc/issue.net on $n is the same as a file in /home/greg/ansible" "inproject \"\$(sum $n)\""
	need "$n has two backups of /etc/issue.net (/etc/issue.net.*~): one old, one from the change" "[ \"\$(in_node $n 'ls -d /etc/issue.net.*~' | wc -l)\" -ge 2 ]"
	need "a backup on $n holds the old banner" "in_node $n 'grep -l \"^Old banner\" /etc/issue.net.*~'"
done

task 2 "/srv/app/conf owned by devops, mode 0750, with app.conf"
for n in $(nodes_names); do
	need "/srv/app/conf on $n is a directory owned by devops with mode 750" "[ \"\$(in_node $n stat -c '%F %U %a' /srv/app/conf)\" = 'directory devops 750' ]"
	need "/srv/app/conf/app.conf on $n has some content" "in_node $n test -s /srv/app/conf/app.conf"
done

task 3 "/etc/hostname fetched from every webserver"
for n in $(nodes_names); do
	need "$A/fetched/$n/etc/hostname holds $n" "[ \"\$(cat $A/fetched/$n/etc/hostname)\" = $n ]"
done
