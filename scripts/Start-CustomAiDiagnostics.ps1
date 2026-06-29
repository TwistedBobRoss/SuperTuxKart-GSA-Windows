$ErrorActionPreference = 'Stop'

$serverfiles = 'C:/serverfiles'
$baseStartScript = 'C:/stk/Start.ps1'
$patchedStartScript = 'C:/temp/Start-CustomAiRuntime.ps1'

if ([string]::IsNullOrWhiteSpace($env:SUPERTUXKART_DATADIR)) {
    $env:SUPERTUXKART_DATADIR = 'C:/stk/stk-code/build-x86_64'
}

if ([string]::IsNullOrWhiteSpace($env:SUPERTUXKART_ASSETS_DIR)) {
    $env:SUPERTUXKART_ASSETS_DIR = 'C:/stk/stk-code/build-x86_64/data'
}

function Show-StkLogs {
    Write-Host '--- SuperTuxKart startup diagnostics ---'

    if (-not (Test-Path -LiteralPath $serverfiles)) {
        Write-Host "No serverfiles directory is available at $serverfiles."
        return
    }

    $logs = Get-ChildItem -LiteralPath $serverfiles -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -eq '.log' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10

    if (-not $logs) {
        Write-Host "No STK log files were found in $serverfiles."
        return
    }

    foreach ($log in $logs) {
        Write-Host "--- Last 200 lines of $($log.FullName) ---"
        try {
            Get-Content -LiteralPath $log.FullName -Tail 200 -ErrorAction Stop | ForEach-Object { Write-Host $_ }
        }
        catch {
            Write-Warning "Could not read $($log.FullName): $($_.Exception.Message)"
        }
    }
}

if (-not (Test-Path -LiteralPath $baseStartScript)) {
    throw "Could not find the base STK startup script at $baseStartScript"
}

$original = [System.IO.File]::ReadAllText($baseStartScript)
$oldServerLaunch = '$serverProcess = Start-StkProcess @("--no-graphics", "--no-sound", "--server-config=$config")'
$newServerLaunch = '$serverProcess = Start-StkProcess @("--no-graphics", "--no-sound", "--stdout=server-startup.log", "--stdout-dir=C:/serverfiles", "--no-console-log", "--server-config=$config")'

if (-not $original.Contains($oldServerLaunch)) {
    throw 'Could not locate the STK server launch command for diagnostic logging.'
}

[System.IO.Directory]::CreateDirectory('C:/temp') | Out-Null
$patched = $original.Replace($oldServerLaunch, $newServerLaunch)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($patchedStartScript, $patched, $utf8NoBom)

Write-Host "SUPERTUXKART_DATADIR=$env:SUPERTUXKART_DATADIR"
Write-Host "SUPERTUXKART_ASSETS_DIR=$env:SUPERTUXKART_ASSETS_DIR"

try {
    & $patchedStartScript
    exit $LASTEXITCODE
}
catch {
    Write-Host "STK startup failed: $($_.Exception.Message)"
    Show-StkLogs
    throw
}
