$ErrorActionPreference = "Stop"

$exe = "C:/stk/stk-code/build-x86_64/bin/supertuxkart.exe"
$config = "C:/serverfiles/server_config.xml"
$workingDirectory = [System.IO.Path]::GetDirectoryName($exe)

if (-not (Test-Path -LiteralPath $exe)) {
    throw "Could not find $exe"
}

if (-not (Test-Path -LiteralPath $config)) {
    throw "Could not find $config. Mount or create C:/serverfiles/server_config.xml before starting."
}

function Format-ArgsForLog {
    param([string[]]$Arguments)

    return ($Arguments | ForEach-Object {
        if ($_ -like "--password=*") {
            "--password=***"
        }
        else {
            $_
        }
    }) -join " "
}

function Invoke-Stk {
    param(
        [string[]]$Arguments,
        [switch]$ExpectLongRunning
    )

    Write-Host ("Running SuperTuxKart with args: {0}" -f (Format-ArgsForLog $Arguments))
    $started = Get-Date

    $process = Start-Process `
        -FilePath $exe `
        -ArgumentList $Arguments `
        -WorkingDirectory $workingDirectory `
        -NoNewWindow `
        -PassThru

    if ($null -eq $process) {
        throw "Failed to start SuperTuxKart process."
    }

    Write-Host "Started SuperTuxKart process id $($process.Id); waiting for it to exit."
    $process.WaitForExit()
    $process.Refresh()

    $duration = ((Get-Date) - $started).TotalSeconds
    if ($null -eq $process.ExitCode) {
        if ($ExpectLongRunning) {
            throw "SuperTuxKart server process exited after $([math]::Round($duration, 1)) seconds without reporting an exit code."
        }
        Write-Warning "SuperTuxKart one-shot command exited after $([math]::Round($duration, 1)) seconds without reporting an exit code; treating this as success."
        return 0
    }

    if ($ExpectLongRunning -and $duration -lt 10) {
        throw "SuperTuxKart server exited after $([math]::Round($duration, 1)) seconds with exit code $($process.ExitCode); expected it to stay running."
    }

    Write-Host "SuperTuxKart exited with code $($process.ExitCode) after $([math]::Round($duration, 1)) seconds."
    return [int]$process.ExitCode
}

function Test-UsableEnvValue {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    return $Value -notmatch '^\s*\{config_parameter\s+id='
}

$username = $env:STK_USERNAME
$password = $env:STK_PASSWORD
$loginRequiredValue = ""
if ($null -ne $env:STK_LOGIN_REQUIRED) {
    $loginRequiredValue = $env:STK_LOGIN_REQUIRED.Trim().ToLowerInvariant()
}
$loginRequired = @("true", "1", "yes") -contains $loginRequiredValue

if ((Test-UsableEnvValue $username) -and (Test-UsableEnvValue $password)) {
    $exitCode = Invoke-Stk @("--no-graphics", "--no-sound", "--init-user", "--login=$username", "--password=$password")
    if ($exitCode -ne 0) {
        $message = "SuperTuxKart account initialization failed with exit code $exitCode"
        if ($loginRequired) {
            throw $message
        }
        Write-Warning "$message; continuing because STK_LOGIN_REQUIRED is not true."
    }
}
else {
    Write-Host "Skipping SuperTuxKart account initialization because usable STK credentials were not provided."
}

$exitCode = Invoke-Stk @("--no-graphics", "--no-sound", "--server-config=$config") -ExpectLongRunning
exit $exitCode
