S=/root/streams
task 1 "Output and errors of ls sent to files"
need "out.txt has the listing of /etc and no error" 'grep -qx passwd $S/out.txt && ! grep -q nonexistent $S/out.txt'
need "err.txt has the error about /nonexistent and no listing" 'grep -q nonexistent $S/err.txt && ! grep -qx passwd $S/err.txt'
need "both.txt has the listing and the error" 'grep -qx passwd $S/both.txt && grep -q nonexistent $S/both.txt'

task 2 "The files with spaces in their names deleted"
need "/root/streams/spaces is still there" '[ -d $S/spaces ]'
need "the three files in it are gone" '[ -z "$(find $S/spaces -name "old report *")" ]'

task 3 "A here-document with the date in it"
need "/root/streams/heredoc.txt has two lines or more" '[ "$(grep -c . $S/heredoc.txt)" -ge 2 ]'
need "it holds the date, not \$(date)" 'grep -q "$(date +%Y)" $S/heredoc.txt && ! grep -qF "\$(date)" $S/heredoc.txt'

task 4 "noclobber tried" self
