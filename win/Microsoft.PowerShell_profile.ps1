# Инициализировать Oh My Posh
oh-my-posh init pwsh --config C:\Users\mym\.poshthemes\honukai.omp.json | Invoke-Expression

# === Functions ===
function ll {
    <#
    .SYNOPSIS
        Показать подробный список файлов и папок по указанному пути.
    #>
    param(
            [Parameter(Position = 0)]
            [string]$Path = '.'
        )

        Get-ChildItem -LiteralPath $Path -Force |
            Format-Table Mode, LastWriteTime, Length, Name, Attributes -AutoSize
}

function grep {
    <#
    .SYNOPSIS
        Поиск текста в файлах.
    #>
   Select-String
}

function touch {
    <#
    .SYNOPSIS
        # Создать файл или обновить время
        touch file.txt

        # Несколько файлов сразу
        touch file1.txt, file2.txt, file3.txt

        # Указать конкретную дату (аналог touch -d)
        touch log.txt -Date "2023-12-01 10:30:00"

        # Только обновить время у существующего файла, не создавать (аналог touch -c)
        touch old.txt -NoCreate

        # Обновить только время доступия (аналог touch -a)
        touch file.txt -AccessTimeOnly

        # Обновить только время модификации (аналог touch -m)
        touch file.txt -ModifyTimeOnly

        # Работает с масками (для существующих файлов)
        touch *.log
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias('FullName')]
        [string[]]$Path,

        [Alias('d')]
        [datetime]$Date = (Get-Date),

        [Alias('c')]
        [switch]$NoCreate,

        [Alias('a')]
        [switch]$AccessTimeOnly,

        [Alias('m')]
        [switch]$ModifyTimeOnly
    )

    process {
        foreach ($file in $Path) {
            # Разрешаем wildcards (*.txt и т.д.)
            if ($file -match '[\*\?]') {
                $resolvedItems = Resolve-Path -Path $file -ErrorAction SilentlyContinue
                if (-not $resolvedItems) {
                    Write-Warning "touch: cannot access '$file': No such file or directory"
                    continue
                }
                $targetPaths = $resolvedItems | Select-Object -ExpandProperty ProviderPath
            }
            else {
                try {
                    $targetPaths = @($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($file))
                }
                catch {
                    Write-Warning "touch: invalid path: $file"
                    continue
                }
            }

            foreach ($target in $targetPaths) {
                $exists = Test-Path -LiteralPath $target

                if (-not $exists) {
                    if ($NoCreate) { continue }

                    $parent = Split-Path -Parent -Path $target
                    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
                        Write-Error "touch: cannot touch '$file': No such file or directory"
                        continue
                    }

                    try {
                        $null = New-Item -ItemType File -Path $target -ErrorAction Stop
                        $exists = $true
                    }
                    catch {
                        Write-Error "touch: cannot create '$file': $_"
                        continue
                    }
                }

                if ($exists) {
                    try {
                        $item = Get-Item -LiteralPath $target

                        # По умолчанию обновляем обе метки
                        if (-not $AccessTimeOnly) {
                            $item.LastWriteTime = $Date
                        }
                        if (-not $ModifyTimeOnly) {
                            $item.LastAccessTime = $Date
                        }
                    }
                    catch {
                        Write-Error "touch: setting times for '$file': $_"
                    }
                }
            }
        }
    }
}

function Use-Java {
    param(
        [ValidateSet('8', '25')]
        [string]$Version
    )

    $env:JAVA_HOME = switch ($Version) {
        '8'  { 'C:\Program Files\Zulu\zulu-8' }
        '25' { 'C:\Program Files\Zulu\zulu-25' }
    }

    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
    java -version
}

# Включаем сохранение истории
Set-PSReadLineOption -HistorySaveStyle SaveAtExit
# Устанавливаем максимальное количество сохраняемых команд
Set-PSReadLineOption -MaximumHistoryCount 10000
# Включаем подсказки из истории при вводе (похоже на zsh/fish)
Set-PSReadLineOption -PredictionSource History
# Показывать список вариантов
Set-PSReadLineOption -PredictionViewStyle ListView
# Включаем цветное автодополнение
Set-PSReadLineOption -Colors @{ InlinePrediction = '#808080' }
# Настройка горячих клавиш для вызова меню
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Устанавливаем кодировку по умолчанию на UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Чтобы алиас "Invoke-WebRequest" не возвращался при каждом запуске
Remove-Item Alias:curl -ErrorAction SilentlyContinue
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
