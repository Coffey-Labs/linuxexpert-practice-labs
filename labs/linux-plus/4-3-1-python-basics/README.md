# Linux+ 4.3.1: Python for administrators

A virtual environment with pinned requirements, the chapter's disk report,
running a command from Python and parsing its JSON, and a style check.

## Before you start

Work as root, so `~` is `/root`. The VM needs internet access to install
from PyPI. The lab only checks that `~/py` doesn't exist yet. Write answers
to the files in `/root/lab-answers/`.

## Tasks

1. In `~/py`, create the virtual environment `.venv` and install `pyyaml`
   into it. Load some YAML with it, save the installed packages to
   `~/py/requirements.txt` with `pip freeze`, and see that the system's
   `python3` can't import `yaml` (unless the distribution's package is
   installed).
2. Save the disk report from the chapter as `~/py/disk.py`, run it, and
   check its exit code.
3. From Python, run `ip -j addr`, parse the JSON, and print each
   interface's name with its list of addresses. Save the output in
   `/root/lab-answers/3`.
4. Install `flake8` into the virtual environment and check `~/py/disk.py`
   with it until it reports nothing.

## Hints

- Ubuntu needs `python3-venv` and `python3-pip` first; `python3 -m venv
  .venv && source .venv/bin/activate`, `pip install`, `pip freeze >
  requirements.txt`, `deactivate`.
- The report uses `shutil.disk_usage` for `/`, `/var` and `/home`, prints
  `MOUNT PERCENT%` lines, and exits 1 if any is at 80% or more.
- `subprocess.run(["ip", "-j", "addr"], capture_output=True, text=True)`,
  `json.loads`, `link.get("addr_info", [])`, `a["local"]`.
- `pip install flake8`, `flake8 ~/py/disk.py`.
