mainpid() { systemctl show -p MainPID --value "$1"; }

task 1 "The stopped process"
need "the stopped process is still there" '[ "$(ps -o stat= -p "$(mainpid le-lab-stopped.service)" | cut -c1)" = T ]'
need "/root/lab-answers/1 has its PID" '[ "$(answer 1)" = "$(mainpid le-lab-stopped.service)" ]'

task 2 "The zombie's parent"
need "/root/lab-answers/2 has the PID of the zombie's parent" '[ "$(answer 2)" = "$(mainpid le-lab-zombie.service)" ]'

task 3 "The busy process"
need "/root/lab-answers/3 has the PID of the process using a core" '[ "$(answer 3)" = "$(mainpid le-lab-busy.service)" ]'

task 4 "The file lab-report reads"
need "/root/lab-answers/4 has the path of its rules file" '[ "$(answer 4)" = /var/lib/lab-report/rules.conf ]'
