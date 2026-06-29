param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDirectory,

    [Parameter(Mandatory = $true)]
    [string]$BuildDirectory
)

$ErrorActionPreference = 'Stop'

$vsDevCmd = 'C:\BuildTools\Common7\Tools\VsDevCmd.bat'
$cmake = 'C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'

foreach ($requiredPath in @($vsDevCmd, $cmake, $SourceDirectory)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required STK build path was not found: $requiredPath"
    }
}

# Keep the whole command in a PowerShell string. This prevents Windows
# PowerShell 5.1 from interpreting cmd.exe's && separators itself.
$command = @"
call "$vsDevCmd" -arch=x64 && if not exist "$BuildDirectory" mkdir "$BuildDirectory" && cd /d "$BuildDirectory" && "$cmake" "$SourceDirectory" -G "Visual Studio 17 2022" -A x64 -DCHECK_ASSETS=OFF && "$cmake" --build . --config Release --target supertuxkart
"@.Trim()

Write-Host "Configuring and building SuperTuxKart from $SourceDirectory"
& $env:ComSpec /d /s /c $command
if ($LASTEXITCODE -ne 0) {
    throw "SuperTuxKart CMake build failed with exit code $LASTEXITCODE."
}
