# Ubuntu Desktop 4.3: Packages from more than one source

Adding and removing a PPA, installing a downloaded `.deb` with dpkg, and
switching a snap between channels.

## Before you start

The lab makes sure `git` is installed and the `hello` deb isn't (reset
puts it back if you had it). The VM needs to reach the Ubuntu archive,
Launchpad and the snap store. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Add the PPA `ppa:git-core/ppa`, find which version of git it offers,
   then remove the PPA without upgrading git. Write the PPA's git version
   to `/root/lab-answers/1`.
2. Download the hello package with `apt-get download hello` (in `/root`),
   and install the file with dpkg.
3. Install the hello snap from the edge channel, then go back to stable.

## Hints

- `add-apt-repository ppa:git-core/ppa` (it runs `apt update` for you);
  `apt-cache policy git` shows a `ppa.launchpadcontent.net` line and the
  Candidate. `add-apt-repository --remove ppa:git-core/ppa` takes it out
  again; afterwards `/etc/apt/sources.list.d/` has only `ubuntu.sources`.
- `dpkg -i hello_*.deb`; `dpkg -l hello` starts with `ii` and `hello`
  prints `Hello, world!`.
- `snap install hello --edge`, `snap refresh hello --stable`; `snap list
  --all hello` shows both revisions.
