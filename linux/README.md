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

## SSH Port

```bash
systemctl edit ssh.socket
```

```ini
[Socket]
ListenStream=
ListenStream=0.0.0.0:2222
ListenStream=[::]:2222
```

```bash
systemctl daemon-reload
systemctl restart ssh.socket

systemctl status ssh.socket
sudo ss -tlnp | grep :2222
```

## UFW

```bash
apt update
apt install ufw

#ufw default deny incoming
#ufw default allow outgoing
ufw allow 2222/tcp

ufw enable
ufw status verbose
```

## FILE2BAN

```bash
apt update
apt install fail2ban

vi /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled = true
port = 2587
# Если ваша система использует systemd для управления логами (по умолчанию в новых версиях Ubuntu),
# может потребоваться следующая строка, чтобы указать Fail2ban читать журнал systemd, а не файл
backend = systemd
```

```bash
systemctl restart fail2ban
fail2ban-client status sshd
```
