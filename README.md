# devops

## Профили

### PowerShell

Профиль PowerShell по умолчанию находится в следующем расположении:

Основной профиль текущего пользователя
```text
$PROFILE

# Или полный путь:
C:\Users\[ИмяПользователя]\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

Различные типы профилей:

1. Текущий пользователь, текущий хост (самый используемый)
```powershell
$PROFILE.CurrentUserCurrentHost
# C:\Users\[Username]\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```
2. Все пользователи, текущий хост
```powershell
$PROFILE.AllUsersCurrentHost
# C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
```
3. Текущий пользователь, все хосты
```powershell
$PROFILE.CurrentUserAllHosts
# C:\Users\[Username]\Documents\Profile.ps1
```
4. Все пользователи, все хосты
```powershell
$PROFILE.AllUsersAllHosts
# C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1
```

Проверка существования профиля:
```powershell
Test-Path $PROFILE
```

Создание профиля если не существует:
```powershell
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -Type File -Force
}
```
[Microsoft.PowerShell_profile.ps1](win/Microsoft.PowerShell_profile.ps1)

### BASH

