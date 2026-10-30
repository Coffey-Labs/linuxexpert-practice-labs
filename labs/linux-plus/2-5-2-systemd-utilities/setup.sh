state_set hostname "$(hostnamectl --static 2>/dev/null || hostname)"
tz=$(timedatectl show -p Timezone --value)
state_set timezone "$tz"
state_set swappiness "$(sysctl -n vm.swappiness)"
case $(hostnamectl --static) in lab-alma.example.test | lab-ubuntu.example.test)
	hostnamectl set-hostname "$(hostnamectl --static | cut -d. -f1)" ;;
esac
case $tz in UTC | Etc/UTC | Etc/UCT | UCT | Universal | Zulu) timedatectl set-timezone America/Phoenix ;; esac
[ "$(sysctl -n vm.swappiness)" != 20 ] || sysctl -qw vm.swappiness=60
