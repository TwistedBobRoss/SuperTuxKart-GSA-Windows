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

function Start-StkProcess {
    param([string[]]$Arguments)

    Write-Host ("Running SuperTuxKart with args: {0}" -f (Format-ArgsForLog $Arguments))
    $process = Start-Process `
        -FilePath $exe `
        -ArgumentList $Arguments `
        -WorkingDirectory $workingDirectory `
        -NoNewWindow `
        -PassThru

    if ($null -eq $process) {
        throw "Failed to start SuperTuxKart process."
    }

    Write-Host "Started SuperTuxKart process id $($process.Id)."
    return $process
}

function Invoke-Stk {
    param(
        [string[]]$Arguments,
        [switch]$ExpectLongRunning
    )

    $started = Get-Date
    $process = Start-StkProcess $Arguments
    Write-Host "Waiting for SuperTuxKart process id $($process.Id) to exit."
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

function Get-ServerConfigValue {
    param(
        [string]$ElementName,
        [string]$DefaultValue
    )

    try {
        [xml]$serverConfig = Get-Content -LiteralPath $config -Raw
        $node = $serverConfig.SelectSingleNode("/server-config/$ElementName")
        if ($node -and (Test-UsableEnvValue $node.value)) {
            return [string]$node.value
        }
    }
    catch {
        Write-Warning "Could not read $ElementName from server config: $($_.Exception.Message)"
    }

    return $DefaultValue
}

function Get-EnvInt {
    param(
        [string]$Name,
        [int]$DefaultValue
    )

    $value = [Environment]::GetEnvironmentVariable($Name)
    if (-not (Test-UsableEnvValue $value)) {
        return $DefaultValue
    }

    $parsed = 0
    if ([int]::TryParse($value, [ref]$parsed)) {
        return $parsed
    }

    Write-Warning "Ignoring non-numeric $Name value '$value'."
    return $DefaultValue
}

function Convert-ToBoolString {
    param(
        [string]$Value,
        [string]$DefaultValue
    )

    if (-not (Test-UsableEnvValue $Value)) {
        return $DefaultValue
    }

    switch ($Value.Trim().ToLowerInvariant()) {
        { $_ -in @("true", "1", "yes", "on") } { return "true" }
        { $_ -in @("false", "0", "no", "off") } { return "false" }
        default {
            Write-Warning "Could not parse boolean value '$Value'; using '$DefaultValue'."
            return $DefaultValue
        }
    }
}

function Set-ServerConfigValue {
    param(
        [xml]$ServerConfig,
        [string]$ElementName,
        [string]$Value
    )

    $node = $ServerConfig.SelectSingleNode("/server-config/$ElementName")
    if (-not $node) {
        $node = $ServerConfig.CreateElement($ElementName)
        $ServerConfig.DocumentElement.AppendChild($node) | Out-Null
    }

    $attribute = $node.Attributes["value"]
    if (-not $attribute) {
        $attribute = $ServerConfig.CreateAttribute("value")
        $node.Attributes.Append($attribute) | Out-Null
    }

    $attribute.Value = $Value
}

function Normalize-ServerConfig {
    param(
        [int]$AiRacers,
        [bool]$HasUsableCredentials,
        [bool]$LoginRequired
    )

    [xml]$serverConfig = Get-Content -LiteralPath $config -Raw

    $wanDefault = if ($HasUsableCredentials -or $LoginRequired) { "true" } else { "false" }
    $aiDefault = if ($AiRacers -gt 0) { "true" } else { "false" }

    $booleanDefaults = @{
        "wan-server" = $wanDefault
        "soccer-goal-target" = "false"
        "enable-console" = "false"
        "chat" = "true"
        "track-voting" = "true"
        "validating-player" = "true"
        "firewalled-server" = "true"
        "ipv6-connection" = "true"
        "owner-less" = "false"
        "auto-end" = "false"
        "team-choosing" = "true"
        "strict-players" = "false"
        "ranked" = "false"
        "server-configurable" = "false"
        "live-spectate" = "true"
        "kick-high-ping-players" = "false"
        "high-ping-workaround" = "true"
        "sql-management" = "false"
        "ai-handling" = $aiDefault
        "ai-anywhere" = "false"
    }

    $envOverrides = @{
        "wan-server" = $env:STK_WAN_SERVER
        "owner-less" = $env:STK_OWNER_LESS
        "ai-handling" = $env:STK_AI_HANDLING
    }

    foreach ($key in $booleanDefaults.Keys) {
        $currentNode = $serverConfig.SelectSingleNode("/server-config/$key")
        $currentValue = if ($currentNode) { [string]$currentNode.value } else { "" }
        if ($envOverrides.ContainsKey($key) -and (Test-UsableEnvValue $envOverrides[$key])) {
            $currentValue = $envOverrides[$key]
        }
        Set-ServerConfigValue $serverConfig $key (Convert-ToBoolString $currentValue $booleanDefaults[$key])
    }

    $serverConfig.Save($config)
}

$username = $env:STK_USERNAME
$password = $env:STK_PASSWORD
$loginRequiredValue = ""
if ($null -ne $env:STK_LOGIN_REQUIRED) {
    $loginRequiredValue = $env:STK_LOGIN_REQUIRED.Trim().ToLowerInvariant()
}
$loginRequired = @("true", "1", "yes") -contains $loginRequiredValue
$hasUsableCredentials = (Test-UsableEnvValue $username) -and (Test-UsableEnvValue $password)
$aiRacers = Get-EnvInt "STK_AI_RACERS" 0
if ($aiRacers -lt 0) {
    $aiRacers = 0
}

Normalize-ServerConfig $aiRacers $hasUsableCredentials $loginRequired

if ($hasUsableCredentials) {
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

$serverPortValue = Get-ServerConfigValue "server-port" "2759"
$serverPort = 2759
if ((-not [int]::TryParse($serverPortValue, [ref]$serverPort)) -or $serverPort -le 0) {
    Write-Warning "Using default STK server port 2759 because server-port '$serverPortValue' is not a usable positive integer."
    $serverPort = 2759
}

$serverPassword = Get-ServerConfigValue "private-server-password" ""

$serverStarted = Get-Date
$serverProcess = Start-StkProcess @("--no-graphics", "--no-sound", "--server-config=$config")
Start-Sleep -Seconds 8
$serverProcess.Refresh()

if ($serverProcess.HasExited) {
    $duration = ((Get-Date) - $serverStarted).TotalSeconds
    if ($null -eq $serverProcess.ExitCode) {
        throw "SuperTuxKart server exited after $([math]::Round($duration, 1)) seconds without reporting an exit code."
    }
    throw "SuperTuxKart server exited after $([math]::Round($duration, 1)) seconds with exit code $($serverProcess.ExitCode); expected it to stay running."
}

if ($aiRacers -gt 0) {
    $aiArgs = @(
        "--no-graphics",
        "--no-sound",
        "--connect-now=127.0.0.1:$serverPort",
        "--network-ai=$aiRacers"
    )
    if (Test-UsableEnvValue $serverPassword) {
        $aiArgs += "--server-password=$serverPassword"
    }

    Write-Host "Starting $aiRacers local SuperTuxKart network AI racer(s). Ensure ai-handling is true in server_config.xml."
    $aiProcess = Start-StkProcess $aiArgs
    Start-Sleep -Seconds 5
    $aiProcess.Refresh()
    if ($aiProcess.HasExited) {
        if ($null -eq $aiProcess.ExitCode) {
            Write-Warning "SuperTuxKart network AI process exited quickly without reporting an exit code."
        }
        else {
            Write-Warning "SuperTuxKart network AI process exited quickly with exit code $($aiProcess.ExitCode)."
        }
    }
}

Write-Host "SuperTuxKart server process id $($serverProcess.Id) is running; waiting for it to exit."
$serverProcess.WaitForExit()
$serverProcess.Refresh()

$serverDuration = ((Get-Date) - $serverStarted).TotalSeconds
if ($null -eq $serverProcess.ExitCode) {
    throw "SuperTuxKart server process exited after $([math]::Round($serverDuration, 1)) seconds without reporting an exit code."
}

Write-Host "SuperTuxKart server exited with code $($serverProcess.ExitCode) after $([math]::Round($serverDuration, 1)) seconds."
exit ([int]$serverProcess.ExitCode)
