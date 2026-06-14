FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

ARG STK_VERSION=1.5
ARG STK_ZIP_URL=https://github.com/supertuxkart/stk-code/releases/download/1.5/SuperTuxKart-1.5-win.zip
ENV STK_ZIP_URL=${STK_ZIP_URL}

WORKDIR C:/stk

RUN New-Item -ItemType Directory -Force -Path C:/temp, C:/stk, C:/serverfiles | Out-Null; \
    Invoke-WebRequest -Uri $env:STK_ZIP_URL -OutFile C:/temp/stk.zip; \
    Expand-Archive -Path C:/temp/stk.zip -DestinationPath C:/temp/stk -Force; \
    $exe = Get-ChildItem -Path C:/temp/stk -Recurse -Filter supertuxkart.exe | Select-Object -First 1; \
    if (-not $exe) { throw 'supertuxkart.exe not found in release zip'; }; \
    Copy-Item -Path (Join-Path $exe.DirectoryName '*') -Destination C:/stk -Recurse -Force; \
    Remove-Item -Recurse -Force C:/temp

COPY Start.ps1 C:/stk/Start.ps1
COPY server_config.xml C:/serverfiles/server_config.xml

EXPOSE 2757/udp
EXPOSE 2759/udp

ENTRYPOINT ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "C:/stk/Start.ps1"]
