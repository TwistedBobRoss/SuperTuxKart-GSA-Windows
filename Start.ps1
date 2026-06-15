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

function Invoke-Stk {
    param([string[]]$Arguments)

    Write-Host ("Running SuperTuxKart with args: {0}" -f ($Arguments -join " "))

    Push-Location $workingDirectory
    try {
        & $exe @Arguments
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($null -eq $exitCode) {
        Write-Warning "SuperTuxKart exited without reporting an exit code; treating this as success."
        return 0
    }

    return [int]$exitCode
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
    $exitCode = Invoke-Stk @("--init-user", "--login=$username", "--password=$password")
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

$exitCode = Invoke-Stk @("--no-graphics", "--server-config=$config")
exit $exitCode
