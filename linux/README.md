# Install additional utility

## AFTER .BASHRC

### Git

Если после запуска у вас `__git_ps1: command not found`:

```bash
apt update
apt install git
source ~/.bashrc
```

### Time

Если после запуска время неправильное: 

```bash
apt update
apt install chrony
systemctl enable --now chrony
chronyc tracking
# Информационно: В утилите chrony (как и в любом другом NTP-клиенте или сервере) нет понятия часового пояса.
```

### Timezone

Если после запуска неправильный часовой пояс: 

```bash
timedatectl set-timezone Africa/Nairobi
```

## New user

```bash
adduser newuser

usermod -aG sudo newuser

mkdir -p /home/newuser/.ssh
vi /home/newuser/.ssh/authorized_keys

chmod 700 /home/newuser/.ssh
chmod 600 /home/newuser/.ssh/authorized_keys
chown -R newuser:newuser /home/newuser/.ssh
```
