$ErrorActionPreference = 'Stop'

$dockerService = Get-Service -Name docker -ErrorAction Stop
if ($dockerService.Status -ne 'Running') {
    Start-Service -Name docker
}

$deadline = (Get-Date).AddMinutes(2)
while ((Get-Date) -lt $deadline) {
    & docker version --format '{{.Server.Version}}' 2>$null
    if ($LASTEXITCODE -eq 0) {
        $osType = (& docker info --format '{{.OSType}}').Trim()
        if ($LASTEXITCODE -ne 0 -or $osType -ne 'windows') {
            throw "Docker started, but is not in Windows-container mode. Detected: '$osType'."
        }
        Write-Host "Windows Docker daemon ready: $osType"
        exit 0
    }
    Start-Sleep -Seconds 2
}

Get-Service -Name docker | Format-List * | Out-String | Write-Host
throw 'The Docker service did not become available within two minutes.'
