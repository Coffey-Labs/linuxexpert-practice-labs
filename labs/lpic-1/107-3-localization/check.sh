task 1 "de_DE.UTF-8 installed; its printf output in /root/lab-answers/1"
need "locale -a lists de_DE.utf8" 'locale -a | grep -qix "de_DE.utf-\?8"'
need "the answer is 1.234.567" '[ "$(answer 1)" = 1.234.567 ]'

task 2 "words.txt sorted under C and under de_DE.UTF-8"
need "/root/lab-answers/2-c is words.txt sorted under LC_ALL=C" '[ -s /root/lab-answers/2-c ] && LC_ALL=C sort /root/words.txt | cmp -s - /root/lab-answers/2-c'
need "/root/lab-answers/2-de is words.txt sorted under LC_ALL=de_DE.UTF-8" '[ -s /root/lab-answers/2-de ] && LC_ALL=de_DE.UTF-8 sort /root/words.txt | cmp -s - /root/lab-answers/2-de'

task 3 "latin1.txt converted to UTF-8 as utf8.txt"
need "/root/latin1.txt holds caf\\xe9 in Latin-1" 'printf "caf\xe9\n" | cmp -s - /root/latin1.txt'
need "/root/utf8.txt holds café in UTF-8" 'printf "caf\xc3\xa9\n" | cmp -s - /root/utf8.txt'
