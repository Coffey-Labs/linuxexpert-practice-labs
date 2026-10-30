for f in /usr/local/bin/count-files /root/homes.sh /root/df-today.sh /root/sumlines.sh; do
	[ -e "$f" ] && refuse "$f already exists; the lab asks you to write it. Remove it and start the lab again."
done
user_add student
rm -f /root/df-[0-9]*.txt
# A directory with hidden and visible entries for the checks.
mkdir -p "$LAB_STATE/count"
touch "$LAB_STATE/count/"{a,b,.c,.d,e}
mkdir "$LAB_STATE/count/.f"
