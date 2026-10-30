# Linux+ 2.5.1: systemd units

A service with a timer, masking and unmasking a unit, and overriding a
vendor unit with a drop-in.

## Before you start

The lab installs `at` (for `atd.service`) and stops and disables `atd`.
Leave your work in place for grading: `le-lab reset` removes the timer and
reverts `atd`.

## Tasks

1. Write `labbeat.service`, a oneshot service that runs `/usr/bin/logger -t
   labbeat "still here"`, and `labbeat.timer`, which runs it every 2
   minutes. Enable and start the timer, and watch the messages arrive in
   the journal.
2. Mask `atd.service` and see that starting it is refused. Then unmask it,
   and make it run now and at every boot.
3. With a drop-in made by `systemctl edit`, run `atd` at nice level 5.
   Check it with `systemctl cat` and `systemctl show -p Nice`. (The chapter
   then reverts it with `systemctl revert atd`; leave it in place here.)

## Hints

- Unit files go in `/etc/systemd/system/`; `OnCalendar=*:0/2`,
  `AccuracySec=1s`, `WantedBy=timers.target`; `systemctl daemon-reload`,
  `systemctl list-timers`, `journalctl -t labbeat`.
- `systemctl mask`, `systemctl unmask`, `systemctl enable --now`.
- `systemctl edit atd`: `[Service]` and `Nice=5`; restart `atd` so the
  running process picks it up.
