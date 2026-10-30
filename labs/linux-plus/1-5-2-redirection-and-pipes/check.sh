R=/tmp/redir

task 1 "Output and errors in out.txt, err.txt, all.txt and only-out.txt"
need "$R/err.txt has the error and no listing" 'grep -q nonexistent $R/err.txt && ! grep -qx passwd $R/err.txt'
need "$R/out.txt has the listing of /etc and no error" 'grep -qx passwd $R/out.txt && ! grep -q nonexistent $R/out.txt'
need "$R/all.txt has both" 'grep -qx passwd $R/all.txt && grep -q nonexistent $R/all.txt'
need "$R/only-out.txt has the listing but not the error" 'grep -qx passwd $R/only-out.txt && ! grep -q nonexistent $R/only-out.txt'

task 2 "Here documents: /tmp/a.txt expanded, /tmp/b.txt as written"
need "/tmp/a.txt says user= and a user name" 'grep -Eqx "user=[a-z_][a-z0-9_.-]*" /tmp/a.txt'
need "/tmp/b.txt says user=\$USER" 'grep -qxF "user=\$USER" /tmp/b.txt'

task 3 "getent passwd saved to /tmp/users.txt with tee"
need "/tmp/users.txt is the output of getent passwd" 'getent passwd | cmp -s - /tmp/users.txt'

task 4 "The files with spaces in /tmp/x removed with find and xargs"
need "/tmp/x is there" '[ -d /tmp/x ]'
need "/tmp/x has no .tmp files left" '[ -z "$(find /tmp/x -name "*.tmp")" ]'
