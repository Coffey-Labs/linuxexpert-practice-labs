M=/home/alice/mirror

task 1 "/srv/projects backed up to /root/projects.tar.gz and restored"
need "/root/projects.tar.gz is a gzip-compressed tar archive" 'tar -tzf /root/projects.tar.gz'
need "the archive has projects/src/app.py" 'tar -tzf /root/projects.tar.gz | grep -Eq "(^|/)projects/src/app\.py$"'
need "/srv/projects has the same files and contents as before" '(cd /srv && find projects -type f -exec sha256sum {} + | sort -k2) | cmp -s - "$LAB_STATE/projects.sha"'
# A new directory has a new inode number or, if the number was reused, a new birth time.
need "/srv/projects was deleted and restored" '[ "$(stat -c "%i %.9W" /srv/projects)" != "$(state_get projects-id)" ]'

task 2 "/srv/site mirrored to alice@peer:mirror with rsync, after a change"
need "rsync is installed" 'command -v rsync'
need "/srv/site/index.html was changed" '[ "$(sha256sum </srv/site/index.html)" != "$(state_get index-sha)" ]'
need "/home/alice/mirror has the same files as /srv/site, including the change" '[ -d $M ] && diff -r /srv/site $M'
need "the copies belong to alice (copied over SSH as alice)" '[ -z "$(find $M ! -user alice)" ]'

task 3 "A snapshot rolled back" self
