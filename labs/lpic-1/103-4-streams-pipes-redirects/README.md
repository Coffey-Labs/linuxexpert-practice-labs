# LPIC-1 103.4: Streams, pipes and redirects

Sending output and errors to files, file names with spaces in pipelines,
here-documents, and `noclobber`.

## Before you start

The lab creates `/root/streams/`, and in `/root/streams/spaces/` three
files with spaces in their names. Work as root (`sudo -i`).

## Tasks

1. Run `ls /etc /nonexistent` with the output going to
   `/root/streams/out.txt` and the errors to `/root/streams/err.txt`,
   then both to `/root/streams/both.txt`. Try `2>&1` before and after `>`
   and compare.
2. Delete the three files in `/root/streams/spaces/` with `find -print0 |
   xargs -0`. Try plain `xargs` first on copies and see it fail.
3. Write a here-document into `/root/streams/heredoc.txt`, and use
   `$(date)` inside it, so the file holds the date it was written.
4. Turn on `set -o noclobber`, try to overwrite a file with `>`, then use
   `>|`. Check it yourself: the first try says "cannot overwrite existing
   file", the second works.

## Hints

- `>`, `2>`, `&>` or `> FILE 2>&1`; `2>&1 > FILE` sends errors to the
  terminal, because they go where output went before the redirect.
- `cp -r spaces copies`, `find copies -type f | xargs rm`;
  `find spaces -type f -print0 | xargs -0 rm`.
- `cat > FILE <<EOF` ... `EOF`; with `<<'EOF'` nothing is expanded.
- `set +o noclobber` turns it off again.
