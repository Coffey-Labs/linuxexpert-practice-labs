task 1 "/tmp/dst mirrors /tmp/src; /tmp/src copied into /tmp/dst2"
need "/tmp/dst/ssh/sshd_config is there" '[ -f /tmp/dst/ssh/sshd_config ]'
need "/tmp/dst/ssh/new.txt is there" '[ -f /tmp/dst/ssh/new.txt ]'
need "/tmp/dst/ssh/moduli is gone (--delete)" '[ ! -e /tmp/dst/ssh/moduli ] && [ ! -e /tmp/src/ssh/moduli ]'
need "/tmp/dst matches /tmp/src" '[ -z "$(rsync -an --delete --out-format=%n /tmp/src/ /tmp/dst/ | grep -v "/$")" ]'
need "/tmp/dst2 has the directory src in it" '[ -d /tmp/dst2/src/ssh ]'

task 2 "The peer's /etc pulled over SSH into /tmp/other-etc as alex"
need "alex has an SSH key the peer accepts" '
	runuser -u alex -- ssh -n -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 alex@10.99.0.2 true'
need "/tmp/other-etc has the peer's /etc files" '[ -f /tmp/other-etc/passwd ] && [ -d /tmp/other-etc/ssh ]'
need "alex made the copy" '[ "$(stat -c %U /tmp/other-etc/passwd)" = alex ]'
need "files only root can read were skipped" '[ ! -e /tmp/other-etc/shadow ]'

task 3 "/dev/loop40 imaged into /tmp/vdb.img"
need "/tmp/vdb.img is identical to /dev/loop40" '[ -f /tmp/vdb.img ] && cmp -s /dev/loop40 /tmp/vdb.img'
