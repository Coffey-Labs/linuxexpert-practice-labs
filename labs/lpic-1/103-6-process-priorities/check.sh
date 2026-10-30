pid=$(state_get pid)
task 1 "Two pinned loops compared" self

task 2 "dana's sleep reniced from 10 to 5"
need "dana's sleep is still running" '[ "$(ps -o user= -p "$pid" | tr -d " ")" = dana ] && [ "$(ps -o comm= -p "$pid")" = sleep ]'
need "it runs at nice 5" '[ "$(ps -o ni= -p "$pid" | tr -d " ")" = 5 ]'

task 3 "nice inside nice bash"
need "/root/lab-answers/3 has what nice prints inside nice bash" '[ "$(answer 3)" = 10 ]'
