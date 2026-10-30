# RHCSA 3.1: Conditions and tests

Scripts that test files, the user running them, whether a user exists,
and whether a service is running.

## Before you start

Write each script where its task says, and make it executable by
everyone. The checks run your scripts, as root and as an unprivileged
user; the check for task 4 stops `chronyd` first and starts it again
afterwards if your script didn't.

## Tasks

1. Write `/usr/local/bin/kind` that prints `file`, `directory` or
   `missing` for the path given as its first argument.
2. Write `/usr/local/bin/amiroot` that prints `root` and exits 0 when run
   as root, and prints `not root` and exits 1 otherwise.
3. Write `/usr/local/bin/userexists` that takes a user name and prints
   whether that user exists: `NAME exists` or `NAME does not exist`.
4. Write `/usr/local/bin/start-chronyd` that starts `chronyd` if it isn't
   running and does nothing otherwise (it prints nothing then).

## Hints

- `[ -d ]`, `[ -f ]`, `[ -e ]`; `if`, `elif`, `else`, `fi`.
- `id -u` is 0 for root, or `$EUID`; `exit 1`.
- `id NAME >/dev/null 2>&1` or `getent passwd NAME`.
- `systemctl is-active --quiet chronyd || systemctl start chronyd`.
- Start each script with `#!/bin/bash`; `chmod 755`.
