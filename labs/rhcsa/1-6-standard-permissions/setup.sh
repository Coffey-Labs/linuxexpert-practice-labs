for d in /srv/reports /srv/project /opt/app; do
	[ -e "$d" ] && refuse "$d already exists; the lab creates or uses it. Remove it and start the lab again."
done
user_add alice
user_add bob
# Task 3: a tree with a mix of modes.
mkdir -p /srv/project/docs/old /srv/project/src/lib /srv/project/bin
for f in README docs/guide.txt docs/old/notes.txt src/main.c src/lib/util.c bin/run.sh; do
	echo "lab file $f" >"/srv/project/$f"
done
chmod 700 /srv/project/docs
chmod 777 /srv/project/src
chmod 750 /srv/project/docs/old
chmod 600 /srv/project/README
chmod 666 /srv/project/src/main.c
chmod 755 /srv/project/bin/run.sh
chmod 640 /srv/project/docs/guide.txt
# Task 4: a readable file in a directory alice can't enter.
mkdir -p /opt/app/conf
echo "port = 8080" >/opt/app/conf/app.conf
chmod 755 /opt/app
chmod 700 /opt/app/conf
chmod 644 /opt/app/conf/app.conf
