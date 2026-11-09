# Install additional utility

## git

Если после запуска у вас `__git_ps1: command not found`:

```bash
apt update
apt install git
source ~/.bashrc
```

## time / timezone

Если после запуска время неправильное: 

```bash
apt update
apt install chrony
systemctl enable --now chrony
chronyc tracking
# Информационно: В утилите chrony (как и в любом другом NTP-клиенте или сервере) нет понятия часового пояса.

# При необходимости установите свою временную зону:
timedatectl set-timezone Africa/Nairobi
```
