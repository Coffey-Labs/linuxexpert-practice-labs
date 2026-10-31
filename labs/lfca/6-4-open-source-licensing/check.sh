# kind NAME KIND: answer 1 has the line "NAME KIND".
kind() { sed 's/^[[:space:]]*//; s/[[:space:]]*$//' /root/lab-answers/1 2>/dev/null | tr 'A-Z' 'a-z' | grep -Eq "^$1[[:space:]:,-]+$2\$"; }

task 1 "The kinds of license in /root/lab-answers/1"
need "bash is copyleft (GPLv3 or later)" 'kind bash copyleft'
need "curl is permissive (the curl license, MIT-style)" 'kind curl permissive'
need "openssl is permissive (Apache 2.0)" 'kind openssl permissive'
need "sqlite is public domain" 'kind sqlite "public[ -]domain"'
need "zlib is permissive (the zlib license)" 'kind zlib permissive'

task 2 "A signed-off commit in ~/practice-repo"
need "git is installed" 'command -v git'
need "/root/practice-repo is a repository with a commit" 'git -C /root/practice-repo rev-parse -q --verify HEAD'
need "a commit has a Signed-off-by line with a name and email" 'git -C /root/practice-repo log --format=%B | grep -Eq "^Signed-off-by: .+ <[^>]+@[^>]+>$"'
