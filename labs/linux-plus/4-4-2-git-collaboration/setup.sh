for f in /root/repo /root/repo2 /root/remote.git; do [ ! -e "$f" ] || refuse "$f already exists; move it away first"; done
command -v git >/dev/null || pkg_install git
export HOME=/root
[ -e /root/.gitconfig ] && state_set had-gitconfig 1
git config --global --get user.name >/dev/null || git config --global user.name "Lab User"
git config --global --get user.email >/dev/null || git config --global user.email lab@example.test
# Chapter 4.4.1 sets this too; without it the bare repository's HEAD is
# master, and the clone in task 1 checks out nothing.
git config --global --get init.defaultBranch >/dev/null || git config --global init.defaultBranch main
# ~/repo as chapter 4.4.1 leaves it.
git init -q -b main /root/repo
cd /root/repo
printf '#!/bin/bash\necho hello\n' >hello.sh && chmod +x hello.sh
git add hello.sh && git commit -q -m "Add hello script"
echo '*.log' >.gitignore; touch run.log
sed -i 's/hello/hello, world/' hello.sh
git add -A && git commit -q -m "Greet the world, ignore logs"
git checkout -q -b feature
echo 'date' >>hello.sh && git commit -q -am "Print the date"
state_set feature "$(git rev-parse HEAD)"
git checkout -q main
cd /
