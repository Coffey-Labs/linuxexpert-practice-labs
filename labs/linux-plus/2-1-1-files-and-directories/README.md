# Linux+ 2.1.1: Files and directories

Building a directory tree, copying it with and without its attributes,
comparing files, and identifying file types.

## Before you start

Work as root, so `~` is `/root`. The lab only checks that `/root/lab`
doesn't exist yet. Leave your work in place for grading: `le-lab reset`
removes `/root/lab`. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Create `~/lab/app` with the subdirectories `conf`, `logs` and `data`,
   and a file `~/lab/app/conf/app.conf` that contains `Listen 80`, with
   mode 640. Copy the tree once with `cp -r` to `~/lab/copy-r` and once with
   `cp -a` to `~/lab/copy-a`, and compare the modify times of the three
   `app.conf` files.
2. Change `80` to `8080` in `~/lab/copy-a/conf/app.conf` only. Save the
   unified diff of the original against that copy in
   `/root/lab-answers/2`.
3. Find the most common file type among the files in `/usr/bin`, and write
   it (as `file` describes it, for example the text before the first comma)
   to `/root/lab-answers/3`.

## Hints

- `mkdir -p` with a brace list, `chmod`, `stat -c '%a %y %n'`.
- `sed -i`, `diff -u`, `sdiff`, `diff -rq`.
- `file /usr/bin/* | awk -F: '{print $2}' | cut -d, -f1 | sort | uniq -c | sort -rn | head`.
