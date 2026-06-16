$Image = "ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r5"
$ContainerName = "twisted-supertuxkart"
$ServerFiles = "C:\stk-test\serverfiles"

New-Item -ItemType Directory -Force -Path $ServerFiles | Out-Null

if (-not (Test-Path -LiteralPath (Join-Path $ServerFiles "server_config.xml"))) {
    Copy-Item -Path ".\server_config.xml" -Destination (Join-Path $ServerFiles "server_config.xml")
}

docker run --name $ContainerName `
  -d `
  -p 2757:2757/udp `
  -p 2759:2759/udp `
  -v "${ServerFiles}:C:\serverfiles" `
  -e STK_USERNAME="" `
  -e STK_PASSWORD="" `
  -e STK_LOGIN_REQUIRED="false" `
  $Image
