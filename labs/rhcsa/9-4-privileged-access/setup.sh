visudo -cq || refuse "sudo's configuration has errors; fix them (visudo -c) and start again"
tar -C /etc -cf "$LAB_STATE/sudoers.tar" sudoers sudoers.d
getent group devs >/dev/null || { groupadd devs; state_set made-devs 1; }
user_add dan -G devs
user_add gina
user_add alice
