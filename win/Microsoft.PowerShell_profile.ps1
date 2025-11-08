# Microsoft.PowerShell_profile.ps1

function Initialize-PSReadLine {
    Write-Host "PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan

    # Для PowerShell 7 используем версию 2.4.4
    if ($PSVersionTable.PSVersion -ge '7.0') {
        $PSReadLinePath = "C:\program files\powershell\7-preview\Modules\PSReadLine\PSReadLine.psd1"
        
        if (Test-Path $PSReadLinePath) {
            Get-Module PSReadLine | Remove-Module -Force -ErrorAction SilentlyContinue
            Import-Module $PSReadLinePath -Force
            Write-Host "PSReadLine 2.4.4 loaded successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "PSReadLine 2.4.4 not found at expected path" -ForegroundColor Yellow
        }
    }

    # Fallback to whatever is available
    if (Get-Module PSReadLine -ListAvailable) {
        Import-Module PSReadLine -Force -ErrorAction SilentlyContinue
        Write-Host "Loaded available PSReadLine version" -ForegroundColor Yellow
        return $true
    }

    return $false
}

# Инициализируем PSReadLine
$PSReadLineAvailable = Initialize-PSReadLine

# Автоматическое перемещение в домашнюю директорию при запуске
Set-Location $HOME

# Установка кодировки
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Настройка внешнего вида
function Set-PowerShellTheme {
    if ($PSReadLineAvailable) {
        $version = (Get-Module PSReadLine).Version
        Write-Host "Configuring PSReadLine $version" -ForegroundColor Gray

        # Базовые настройки
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineOption -ShowToolTips
        Set-PSReadLineOption -BellStyle None
        Set-PSReadLineOption -EditMode Windows

        # Расширенные настройки для версий 2.1.0+
        if ($version -ge '2.1.0') {
            try {
                Set-PSReadLineOption -PredictionViewStyle ListView
                Set-PSReadLineOption -Colors @{
                    Command            = 'Yellow'
                    Parameter          = 'Cyan'
                    String             = 'Green'
                    Number             = 'White'
                    Type               = 'Gray'
                    Variable           = 'Red'
                    Operator           = 'DarkGray'
                    Member             = 'Gray'
                }
                # Set-PSReadLineOption -SelectionBackgroundColor 'DarkBlue'
                Write-Host "Advanced PSReadLine features enabled" -ForegroundColor Green
            }
            catch {
                Write-Host "Some advanced features not available: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "PSReadLine not available - using basic configuration" -ForegroundColor Red
    }
}

Set-PowerShellTheme

# Полезные алиасы
Set-Alias which Get-Command
Set-Alias open Invoke-Item

# Быстрая навигация
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function ~ { Set-Location $HOME }

# аналог 'ls --color=yes -hAlF --group-directories-first'
function la {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Path = ".",
        [switch]$Recurse
    )

    # Получаем все элементы, включая скрытые
    $items = Get-ChildItem -Path $Path -Recurse:$Recurse -Force -ErrorAction SilentlyContinue

    function Get-OwnerPermissions {
        param($file)
        if ($file.PSIsContainer) { $permissions = "d" } else { $permissions = "-" }
        $readOnly = [bool]($file.Attributes -band [System.IO.FileAttributes]::ReadOnly)
        $isExecutable = Test-IsExecutableFile $file
        $permissions += if ($readOnly) { "r-" } else { "rw" }
        $permissions += if ($isExecutable -or $file.PSIsContainer) { "x" } else { "-" }
        return $permissions
    }

    # Это исполняемый файл
    function Test-IsExecutableFile {
        param($file)
        $executableExtensions = @('.exe', '.com', '.bat', '.cmd', '.ps1', '.msi', '.scr', '.pif')
        $byExtension = $executableExtensions -contains $file.Extension.ToLower()
        return $byExtension
    }

    # Подсчет общего размера
    $totalSize = ($items | Where-Object { !$_.PSIsContainer } | Measure-Object -Sum Length).Sum

    # Форматирование общего размера
    $totalSizeFormatted = switch ($totalSize) {
        {$_ -lt 1KB} { "{0}B" -f $_ }
        {$_ -lt 1MB} { "{0:N2}KB" -f ($_ / 1KB) }
        {$_ -lt 1GB} { "{0:N2}MB" -f ($_ / 1MB) }
        default { "{0:N2}GB" -f ($_ / 1GB) }
    }

    # Выводим общую информацию
    Write-Host "Total $totalSizeFormatted"

    # Собираем данные для всех элементов
    $tableData = @()

    # Разделяем директории и файлы
    $directories = $items | Where-Object { $_.PSIsContainer } | Sort-Object Name
    $files = $items | Where-Object { !$_.PSIsContainer } | Sort-Object Name

    # ИСПРАВЛЕНИЕ: Объединяем директории и файлы правильно
    $allItems = @($directories) + @($files)

    # Форматируем вывод
    foreach ($item in $allItems) {
        $name = $item.Name
        $permissions = Get-OwnerPermissions $item
        $size = if ($item.PSIsContainer) { "0" }
            elseif ($item.Length -gt 0) {
                if ($item.Length -lt 1KB) { "$($item.Length)B" }
                elseif ($item.Length -lt 1MB) { "{0:N2}KB" -f ($item.Length / 1KB) }
                elseif ($item.Length -lt 1GB) { "{0:N2}MB" -f ($item.Length / 1MB) }
                else { "{0:N2}GB" -f ($item.Length / 1GB) }
            } else { "0" }

        # Получаем информацию о владельце
        try {
            $acl = Get-Acl -Path $item.FullName
            $owner = $acl.Owner
            $ownerUser = "$($owner.Split('\')[1])"
            $ownerGroup = "$($owner.Split('\')[0])"
        } catch {
            $ownerUser = "N/A"
            $ownerGroup = "N/A"
        }

        # Получаем время последнего изменения
        $lastModified = $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")

        # ИСПРАВЛЕНИЕ: Используем правильную переменную
        if ($item.PSIsContainer) { 
            $displayName = $name + "/" 
        }
        elseif ([bool]($item.Attributes -band [System.IO.FileAttributes]::Hidden)) { 
            $displayName = "." + $name 
        }
        else { 
            $displayName = $name 
        }

        $tableData += [PSCustomObject]@{
            Permissions = $permissions
            OwnerUser = $ownerUser
            OwnerGroup = $ownerGroup
            Size = $size
            LastModified = $lastModified
            Name = $displayName
            IsDirectory = $item.PSIsContainer
            IsExecutable = Test-IsExecutableFile $item
            RawName = $name
        }
    }

    # Определяем максимальные ширины колонок
    $maxPermissions = ($tableData.Permissions | Measure-Object -Property Length -Maximum).Maximum
    $maxOwnerUser = ($tableData.OwnerUser | Measure-Object -Property Length -Maximum).Maximum
    $maxOwnerGroup = ($tableData.OwnerGroup | Measure-Object -Property Length -Maximum).Maximum
    $maxSize = ($tableData.Size | Measure-Object -Property Length -Maximum).Maximum
    $maxLastModified = ($tableData.LastModified | Measure-Object -Property Length -Maximum).Maximum

    # Выводим данные с выравниванием
    foreach ($row in $tableData) {
        # Права доступа
        Write-Host $row.Permissions.PadRight($maxPermissions) -ForegroundColor DarkGray -NoNewline
        Write-Host " " -NoNewline

        # Владелец Пользователь
        Write-Host $row.OwnerUser.PadRight($maxOwnerUser) -NoNewline
        Write-Host " " -NoNewline

        # Владелец Группа
        Write-Host $row.OwnerGroup.PadRight($maxOwnerGroup) -NoNewline
        Write-Host " " -NoNewline

        # Размер
        Write-Host $row.Size.PadLeft($maxSize) -NoNewline
        Write-Host " " -NoNewline

        # Дата изменения
        Write-Host $row.LastModified.PadRight($maxLastModified) -NoNewline
        Write-Host " " -NoNewline

        # Имя файла/папки с цветами
        if ($row.IsDirectory) { Write-Host $row.Name -ForegroundColor Cyan }
        elseif ($row.IsExecutable) { Write-Host $row.Name -ForegroundColor Green }
        else { Write-Host $row.Name }
    }
}
# аналог touch
function touch {
    <#
    .SYNOPSIS
        Unix-like touch command for PowerShell
    
    .DESCRIPTION
        Enhances New-Item by providing touch-like behavior:
        - Creates file if it doesn't exist
        - Updates timestamp if it exists
        - Better pipeline support and syntax
    
    .PARAMETER Path
        File path(s) to create or update
    
    .EXAMPLE
        touch file.txt
        touch *.log, *.tmp
        Get-ChildItem *.cs | touch
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("FullName")]
        [string[]]$Path
    )
    
    process {
        foreach ($filePath in $Path) {
            try {
                if (Test-Path $filePath) {
                    # Файл существует - обновляем timestamp
                    if ($PSCmdlet.ShouldProcess($filePath, "Update timestamp")) {
                        (Get-Item $filePath).LastWriteTime = Get-Date
                        Write-Verbose "Updated: $filePath"
                    }
                } else {
                    # Файл не существует - создаем через New-Item
                    if ($PSCmdlet.ShouldProcess($filePath, "Create file")) {
                        $null = New-Item -Path $filePath -ItemType File -Force
                        Write-Verbose "Created: $filePath"
                    }
                }
            }
            catch {
                Write-Error "Error processing '$filePath': $($_.Exception.Message)"
            }
        }
    }
}

# Поиск в истории команд
function search-history {
    $history = Get-Content (Get-PSReadLineOption).HistorySavePath
    $history | Where-Object { $_ -like "*$args*" } | Select-Object -Last 20
}

# Быстрый переход к часто используемым папкам
function proj { Set-Location "C:\Projects" }
function proj_java { Set-Location "C:\Projects\java" }
function docs { Set-Location "C:\Users\$env:USERNAME\Documents" }
function downloads { Set-Location "C:\Users\$env:USERNAME\Downloads" }
function credo { Set-Location "C:\Users\$env:USERNAME\Downloads\Credo" }
function mymsoft { Set-Location "C:\Users\$env:USERNAME\Downloads\mymsoft" }
function moek { Set-Location "C:\Users\$env:USERNAME\Downloads\moek" }

# Информация о системе
function sysinfo {
    Write-Host "=== System Information ===" -ForegroundColor Cyan
    Write-Host "User: $env:USERNAME" -ForegroundColor Yellow
    Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor Yellow
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "OS: $([System.Environment]::OSVersion.VersionString)" -ForegroundColor Yellow
    Write-Host "==========================" -ForegroundColor Cyan
}

# Приветственное сообщение
function Show-Welcome {
    Write-Host "=== PowerShell $($PSVersionTable.PSVersion) ===" -ForegroundColor Green
    Write-Host "Profile loaded from: $PROFILE" -ForegroundColor Gray
    Write-Host "------------------------" -ForegroundColor Gray
    Write-Host "Type 'proj' for Projects" -ForegroundColor Gray
    Write-Host "Type 'docs' for Documents" -ForegroundColor Gray
    Write-Host "Type 'downloads' for Downloads" -ForegroundColor Gray
    Write-Host "Type 'credo' for Credo" -ForegroundColor Gray
    Write-Host "Type 'moek' for MOEK" -ForegroundColor Gray
    Write-Host "Type 'mymsoft' for mymsoft" -ForegroundColor Gray
    Write-Host "------------------------" -ForegroundColor Gray
    Write-Host "Type 'sysinfo' for system information" -ForegroundColor Gray
    Write-Host "Type 'Get-Help about_Profiles' for help" -ForegroundColor Gray
}

Show-Welcome
