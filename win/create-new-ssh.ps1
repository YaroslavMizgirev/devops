$path = Read-Host "Полный путь к файлу ключа (C:\Users\mym\.ssh\new-folder\id_ed25519)"
$comment = Read-Host "Комментарий к ключу"
# $passphrase = Read-Host "Парольная фраза" -AsSecureString

if ([string]::IsNullOrWhiteSpace($path)) {
    Write-Error "Путь к папке ключа не указан"
    return
}

try {
    $folder = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
        throw "По указанному пути существует файл, а не папка."
    } else {
        New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    }

    if ((Test-Path -LiteralPath $path) -or (Test-Path -LiteralPath "$path.pub")) {
        throw "Файл ключа или файл открытого ключа уже существует. Выбери другое имя."
    }

    # ssh-keygen -t ed25519 -f $path -C $comment -N $passphrase
    ssh-keygen -t ed25519 -f $path -C $comment
    if ($LASTEXITCODE -ne 0) {
        throw "Не удалось создать ключ. Код ошибки: $LASTEXITCODE."
    }
    Write-Host "Закрытый ключ: $path"
    Write-Host "Открытый ключ: $path.pub"
} catch {
    Write-Error $_
}
