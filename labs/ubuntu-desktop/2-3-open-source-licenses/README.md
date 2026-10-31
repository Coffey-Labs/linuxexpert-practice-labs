# Ubuntu Desktop 2.3: Open source licenses

Reading the licenses of installed packages, telling copyleft from
permissive, and finding which archive component a package comes from.

## Before you start

The lab changes nothing. Write your answers to the files in
`/root/lab-answers/`, one item per line.

## Tasks

1. Find the license of the `bash` package and of the `openssl` package,
   and say which of them could be built into a closed-source product.
   Write bash's main license on line 1 of `/root/lab-answers/1`,
   openssl's on line 2, and the package that could be built in on line 3.
2. Find which component `ubuntu-drivers-common` comes from, and which
   component NVIDIA's driver `nvidia-driver-535` is in. Write them on
   lines 1 and 2 of `/root/lab-answers/2`.
3. Count how many installed packages carry a GPL license of any version,
   and write the number to `/root/lab-answers/3`.

## Hints

- `grep '^License:' /usr/share/doc/PACKAGE/copyright`; a few files in a
  package can have other licenses than the main one.
- `apt-cache show PACKAGE | grep -m1 Section`: a section with no prefix
  is in `main`, otherwise the prefix is the component.
- `grep -l` over `/usr/share/doc/*/copyright`, then `wc -l`. Rough
  counts are fine.
