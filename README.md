# SuperTuxKart Windows GSA Blueprint

Windows-container experiment for running a SuperTuxKart dedicated server through GameServerApp.

This repo contains:

- `Dockerfile` - builds a Windows Server Core image using the official SuperTuxKart Windows release zip.
- `Start.ps1` - initializes an optional STK online account, then starts the server from `server_config.xml`.
- `server_config.xml` - default editable STK server config.
- `docker-run.example.ps1` - local test command.
- `docker-run.gsa-import.txt` - GSA Docker import command with config parameters wired into container environment variables.
- `blueprints/supertuxkart-gsa-windows.json` - GSA blueprint import draft.
- `.github/workflows/build-ghcr.yml` - GitHub Actions workflow that builds and publishes the Windows container image.

## Build With GitHub Actions

The easiest path is to use the included GitHub Actions workflow:

1. Open the repo's **Actions** tab.
2. Select **Build and publish Windows container**.
3. Click **Run workflow**.

The workflow publishes these tags to GitHub Container Registry:

```text
ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r3
ghcr.io/twistedbobross/supertuxkart-gsa-windows:latest
```

After the first successful build, make sure the GHCR package is public if GSA will pull it without registry credentials.

## Build Locally

Run this on a Windows Docker host using Windows containers:

```powershell
docker build -t ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r3 .
```

## Test

```powershell
.\docker-run.example.ps1
docker logs twisted-supertuxkart
```

## GSA Import

For a fresh GameServerApp custom Docker blueprint, import `docker-run.gsa-import.txt` or paste its single-line `docker run` command. This wires the STK account parameters into the container environment variables:

```text
STK_USERNAME={config_parameter id="stk_username"}
STK_PASSWORD={config_parameter id="stk_password"}
STK_LOGIN_REQUIRED={config_parameter id="stk_login_required"}
```

If you created a server from an older command where `STK_USERNAME` and `STK_PASSWORD` were blank, update the blueprint Docker environment variables and reinstall/recreate the game server. Container environment variables are set when the container is created; changing config parameter values later will not repair an already-created container with blank env vars.

## Publish

GSA pulls images from a registry. After testing, push the image to GitHub Container Registry:

```powershell
docker push ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r3
```

Then import `blueprints/supertuxkart-gsa-windows.json` in GameServerApp.

## Notes

- Main server port: UDP `2759`.
- Discovery port: UDP `2757`.
- Public/WAN listing requires an STK online account. Fill `STK_USERNAME` and `STK_PASSWORD`, set `wan_server=true`, and set `STK_LOGIN_REQUIRED=true` if a bad login should stop the server.
- For first direct-connect tests, leave `wan_server=false` and `STK_LOGIN_REQUIRED=false`.
- The image explicitly uses the x86_64 SuperTuxKart Windows binary from the combined Windows release archive.
- The initial version uses the official Windows release binary, not a dedicated server-only Windows build.
- If the official binary refuses to run headless inside a Windows container, the next step is building SuperTuxKart from source with `SERVER_ONLY=ON`.
