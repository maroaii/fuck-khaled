<#
.SYNOPSIS
    Compress Chrome cookies, saved passwords and Telegram Desktop session data

.DESCRIPTION
    Gathers:
      - Chrome Cookies (SQLite file)
      - Chrome Login Data (saved passwords)
      - Telegram Desktop tdata folder (session files)
    Packs them into a single ZIP for easy download or transfer.

.EXAMPLE
    .\save_creds_and_tgdata.ps1
    # creates C:\chrome_tg_backup.zip

    .\save_creds_and_tgdata.ps1 "D:\backups\chrome_tg_backup.zip"
#>

Param(
    [string]$OutFile = "$env:USERPROFILE\chrome_tg_backup.zip"
)

# Define the paths to include
$items = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
    "$env:APPDATA\Telegram Desktop\tdata\*"
)

# Filter only existing paths
$existing = $items | Where-Object { Test-Path $_ }
if (-not $existing) {
    Write-Error "No files or folders found to compress."
    exit 1
}

Write-Host "Compressing the following into:`n $($existing -join "`n ")`n→ $OutFile`n" -ForegroundColor Cyan

# Perform the compression
Compress-Archive -LiteralPath $existing -DestinationPath $OutFile -Force

Write-Host "`nDone! Archive created at:`n $OutFile" -ForegroundColor Green
