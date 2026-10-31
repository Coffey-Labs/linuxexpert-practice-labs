# Ubuntu Desktop 4.4: Package descriptions

Finding which package owns a file, reading a package's description
without installing it, and finding what depends on a library.

## Before you start

The lab changes nothing. Write your answers to the files in
`/root/lab-answers/`, one item per line.

## Tasks

1. Find which package provides `/usr/bin/lsblk`, and how many files that
   package installs. Write the package's name on line 1 of
   `/root/lab-answers/1` and the count on line 2.
2. Find the component, maintainer and download size of the `synaptic`
   package, without installing it. Write the component on line 1 of
   `/root/lab-answers/2`, the maintainer's name on line 2 and the download
   size on line 3.
3. Before removing `libncursesw6`, find which installed packages depend on
   it. Write their names to `/root/lab-answers/3`, one per line.

## Hints

- `dpkg -S`, `dpkg -L PACKAGE | wc -l`.
- `apt show` (or `apt-cache show`): the component is the part of
  `Section:` before the slash, or `main` if there's no slash.
- `apt-cache rdepends --installed`; it lists some names twice.
