$ErrorActionPreference = "Stop"

$exe = "C:\stk\supertuxkart.exe"
$config = "C:\serverfiles\server_config.xml"

if (-not (Test-Path -LiteralPath $exe)) {
    throw "Could not find $exe"
}

if (-not (Test-Path -LiteralPath $config)) {
    throw "Could not find $config. Mount or create C:\serverfiles\server_config.xml before starting."
}

$username = $env:STK_USERNAME
$password = $env:STK_PASSWORD

if (-not [string]::IsNullOrWhiteSpace($username) -and -not [string]::IsNullOrWhiteSpace($password)) {
    & $exe --init-user "--login=$username" "--password=$password"
    if ($LASTEXITCODE -ne 0) {
        throw "SuperTuxKart account initialization failed with exit code $LASTEXITCODE"
    }
}

& $exe "--server-config=$config"
exit $LASTEXITCODE
