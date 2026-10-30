groupadd -f students
user_add student1 -s /bin/bash -G students
user_add student2 -s /bin/bash -G students
user_add alice -s /bin/bash
state_set alice-uid "$(id -u alice)"

# Keep the limits files, so that reset can put them back.
saved=$LAB_STATE/saved
mkdir -p "$saved/etc/security"
cp -a /etc/security/limits.conf /etc/security/limits.d "$saved/etc/security/"

# The running process for task 4.
cat >/usr/local/bin/lab-worker <<'X'
#!/bin/bash
# Practice lab worker: does nothing, slowly.
while :; do sleep 60; done
X
chmod 755 /usr/local/bin/lab-worker
cat >/etc/systemd/system/lab-worker.service <<'X'
[Unit]
Description=Practice lab worker

[Service]
User=alice
ExecStart=/usr/local/bin/lab-worker
LimitNOFILE=512:1024

[Install]
WantedBy=multi-user.target
X
command -v restorecon >/dev/null && restorecon /usr/local/bin/lab-worker /etc/systemd/system/lab-worker.service
systemctl daemon-reload
systemctl enable --now --quiet lab-worker.service

# A key for check.sh to log in over ssh as student2.
ssh-keygen -q -t ed25519 -N '' -C le-lab -f "$LAB_STATE/ssh-key"
install -d -m 700 -o student2 -g student2 /home/student2/.ssh
install -m 600 -o student2 -g student2 "$LAB_STATE/ssh-key.pub" /home/student2/.ssh/authorized_keys
command -v restorecon >/dev/null && restorecon -R /home/student2/.ssh
true
