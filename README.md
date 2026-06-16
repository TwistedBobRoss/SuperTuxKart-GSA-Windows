# SuperTuxKart Windows GSA Blueprint

Windows-container experiment for running a SuperTuxKart dedicated server through GameServerApp.

This repo contains:

- `Dockerfile` - builds a Windows Server Core image using the official SuperTuxKart Windows release zip.
- `Start.ps1` - initializes an optional STK online account, then starts the server from `server_config.xml`.
- `server_config.xml` - default editable STK server config.
- `docker-run.example.ps1` - local test command.
- `docker-run.gsa-import.txt` - simple GSA Docker import seed command.
- `blueprints/supertuxkart-gsa-windows.json` - GSA blueprint import draft with config parameters wired into Docker env vars.
- `.github/workflows/build-ghcr.yml` - GitHub Actions workflow that builds and publishes the Windows container image.

## Build With GitHub Actions

The easiest path is to use the included GitHub Actions workflow:

1. Open the repo's **Actions** tab.
2. Select **Build and publish Windows container**.
3. Click **Run workflow**.

The workflow publishes these tags to GitHub Container Registry:

```text
ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r5
ghcr.io/twistedbobross/supertuxkart-gsa-windows:latest
```

After the first successful build, make sure the GHCR package is public if GSA will pull it without registry credentials.

## Build Locally

Run this on a Windows Docker host using Windows containers:

```powershell
docker build -t ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r5 .
```

## Test

```powershell
.\docker-run.example.ps1
docker logs twisted-supertuxkart
```

## GSA Import

Best option: import `blueprints/supertuxkart-gsa-windows.json`. That file already wires the STK account parameters into Docker environment variables.

If you use GameServerApp's **Import Custom Docker container** flow, paste the simple command from `docker-run.gsa-import.txt`. It is intentionally not fully parameterized, because the Docker run import parser may ignore quoted `{config_parameter ...}` values. After import, edit **Docker > Environment variables** in the blueprint:

```text
STK_USERNAME = {config_parameter id="stk_username"}
STK_PASSWORD = {config_parameter id="stk_password"}
STK_LOGIN_REQUIRED = {config_parameter id="stk_login_required"}
```

For a private test blueprint, you can instead put the literal STK username/password directly in those Docker env rows. Do not publish credentials in a marketplace blueprint.

If you created a server from an older command where `STK_USERNAME` and `STK_PASSWORD` were blank, update the blueprint Docker environment variables and reinstall/recreate the game server. Container environment variables are set when the container is created; changing config parameter values later will not repair an already-created container with blank env vars.

## Publish

GSA pulls images from a registry. After testing, push the image to GitHub Container Registry:

```powershell
docker push ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r5
```

Then import `blueprints/supertuxkart-gsa-windows.json` in GameServerApp.

## Notes

- Main server port: UDP `2759`.
- Discovery port: UDP `2757`.
- Public/WAN listing requires an STK online account. Fill `STK_USERNAME` and `STK_PASSWORD`, set `wan_server=true`, and set `STK_LOGIN_REQUIRED=true` if a bad login should stop the server.
- r5 launches STK with `--no-graphics`, masks `--password` in wrapper logs, and waits on the actual STK process so a quick exit is treated as a failed server start instead of a false success.
- The image explicitly uses the x86_64 SuperTuxKart Windows binary from the combined Windows release archive.
- The initial version uses the official Windows release binary, not a dedicated server-only Windows build.
- If the official binary still refuses to run headless inside a Windows container, the next step is building SuperTuxKart from source with `SERVER_ONLY=ON`.
