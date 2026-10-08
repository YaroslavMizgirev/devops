# Профили PowerShell

Профиль PowerShell по умолчанию находится в следующем расположении:

Основной профиль текущего пользователя
```shell
$PROFILE

# Или полный путь:
C:\Users\[ИмяПользователя]\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```
Различные типы профилей:

Текущий пользователь, текущий хост (самый используемый)
```shell
$PROFILE.CurrentUserCurrentHost
# C:\Users\[Username]\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```
Все пользователи, текущий хост
```shell
$PROFILE.AllUsersCurrentHost
# C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
```
Текущий пользователь, все хосты
```shell
$PROFILE.CurrentUserAllHosts
# C:\Users\[Username]\Documents\Profile.ps1
```
Все пользователи, все хосты
```shell
$PROFILE.AllUsersAllHosts
# C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1
```
Проверка существования профиля:
```shell
Test-Path $PROFILE
```
Создание профиля если не существует:
```shell
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -Type File -Force
}
```
