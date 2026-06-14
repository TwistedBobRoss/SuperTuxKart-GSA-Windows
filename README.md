# SuperTuxKart Windows GSA Blueprint

Windows-container experiment for running a SuperTuxKart dedicated server through GameServerApp.

This repo contains:

- `Dockerfile` - builds a Windows Server Core image using the official SuperTuxKart Windows release zip.
- `Start.ps1` - initializes an optional STK online account, then starts the server from `server_config.xml`.
- `server_config.xml` - default editable STK server config.
- `docker-run.example.ps1` - local test command.
- `blueprints/supertuxkart-gsa-windows.json` - GSA blueprint import draft.

## Build

Run this on a Windows Docker host using Windows containers:

```powershell
docker build -t ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022 .
```

## Test

```powershell
.\docker-run.example.ps1
docker logs twisted-supertuxkart
```

## Publish

GSA pulls images from a registry. After testing, push the image to GitHub Container Registry:

```powershell
docker push ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022
```

Then import `blueprints/supertuxkart-gsa-windows.json` in GameServerApp.

## Notes

- Main server port: UDP `2759`.
- Discovery port: UDP `2757`.
- Public/WAN listing requires an STK online account. Fill `STK_USERNAME` and `STK_PASSWORD`, and set `wan_server=true` in the config template.
- The initial version uses the official Windows release binary, not a dedicated server-only Windows build.
- If the official binary refuses to run headless inside a Windows container, the next step is building SuperTuxKart from source with `SERVER_ONLY=ON`.
