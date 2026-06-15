$ErrorActionPreference = "Stop"

$exe = "C:\stk\stk-code\build-x86_64\bin\supertuxkart.exe"
$config = "C:\serverfiles\server_config.xml"
$workingDirectory = [System.IO.Path]::GetDirectoryName($exe)

if (-not (Test-Path -LiteralPath $exe)) {
    throw "Could not find $exe"
}

if (-not (Test-Path -LiteralPath $config)) {
    throw "Could not find $config. Mount or create C:\serverfiles\server_config.xml before starting."
}

function Invoke-Stk {
    param([string[]]$Arguments)

    Push-Location -LiteralPath $workingDirectory
    try {
        & $exe @Arguments
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    return $exitCode
}

$username = $env:STK_USERNAME
$password = $env:STK_PASSWORD

if (-not [string]::IsNullOrWhiteSpace($username) -and -not [string]::IsNullOrWhiteSpace($password)) {
    $exitCode = Invoke-Stk @("--init-user", "--login=$username", "--password=$password")
    if ($exitCode -ne 0) {
        throw "SuperTuxKart account initialization failed with exit code $exitCode"
    }
}

$exitCode = Invoke-Stk @("--server-config=$config")
exit $exitCode
