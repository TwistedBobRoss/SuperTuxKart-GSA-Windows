# SuperTuxKart GSA Windows Container

Ready-to-use Windows container and GameServerApp blueprint for hosting a SuperTuxKart dedicated server.

SuperTuxKart is a free, open-source arcade kart racing game with online multiplayer, track voting, several race modes, and AI racers. This project packages the Windows server flow for GameServerApp so you can run a public or private lobby without building the container yourself.

## Container Image

Use the pinned image tag for predictable installs:

```text
ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r8
```

The `latest` tag is also published, but the pinned tag is recommended for GameServerApp blueprints.

This image is intended for **Windows container hosts**, such as Windows Server 2022 with Docker configured for Windows containers. It is not a Linux container image.

## What This Provides

- Prebuilt Windows container image for SuperTuxKart `1.5`
- GameServerApp blueprint JSON
- Editable `server_config.xml`
- WAN/public server listing support
- Optional SuperTuxKart account login at startup
- Optional local network AI racers
- Track voting and lobby settings
- Private server password support
- GSA config parameters wired into Docker environment variables
- Startup wrapper that normalizes boolean config values before launching STK

## GameServerApp Setup

The easiest path is to import the blueprint:

```text
https://raw.githubusercontent.com/TwistedBobRoss/SuperTuxKart-GSA-Windows/main/blueprints/supertuxkart-gsa-windows.json
```

After importing, create a server from the blueprint and fill in the config parameters.

Recommended public/WAN setup:

```text
WAN/Public Server = true
Require STK Login = true
STK Account Username = your STK account username
STK Account Password = your STK account password
Ownerless Lobby = false
AI Handling = true, if using AI racers
AI Racers = desired AI count
```

Recommended private/local test setup:

```text
WAN/Public Server = false
Require STK Login = false
AI Racers = 0
AI Handling = false
Ownerless Lobby = false
```

If you change Docker image settings or Docker environment variables after creating a server, reinstall or recreate the server so the container receives the updated values.

## Docker Environment Variables

The blueprint should create these automatically:

```text
STK_USERNAME = {config_parameter id="stk_username"}
STK_PASSWORD = {config_parameter id="stk_password"}
STK_LOGIN_REQUIRED = {config_parameter id="stk_login_required"}
STK_AI_RACERS = {config_parameter id="ai_racers"}
STK_WAN_SERVER = {config_parameter id="wan_server"}
STK_OWNER_LESS = {config_parameter id="owner_less"}
STK_AI_HANDLING = {config_parameter id="ai_handling"}
```

For a private test blueprint, you may use literal values instead. Do not publish a marketplace blueprint containing real account credentials.

## Docker Run Example

For a direct Docker test outside GSA:

```powershell
docker run -d --name supertuxkart-gsa-test `
  -p 2757:2757/udp `
  -p 2759:2759/udp `
  -v C:\stk-test\serverfiles:C:\serverfiles `
  -e STK_USERNAME="" `
  -e STK_PASSWORD="" `
  -e STK_LOGIN_REQUIRED="false" `
  -e STK_AI_RACERS="0" `
  -e STK_WAN_SERVER="false" `
  -e STK_OWNER_LESS="false" `
  -e STK_AI_HANDLING="false" `
  ghcr.io/twistedbobross/supertuxkart-gsa-windows:1.5-ltsc2022-x86_64-r8
```

For WAN/public listing, provide valid STK credentials and set:

```text
STK_LOGIN_REQUIRED=true
STK_WAN_SERVER=true
```

## Ports

```text
2757/UDP = discovery/raw port
2759/UDP = game/server port
```

## Configuration File

The main editable config is:

```text
\serverfiles\server_config.xml
```

Inside the container, it is mounted at:

```text
C:/serverfiles/server_config.xml
```

## MOTD

The message of the day is edited directly in `server_config.xml`:

```xml
<motd value="Welcome to {gameserver.list_name}!" />
```

Example:

```xml
<motd value="Welcome to Twisted Kittens Karting!" />
```

Escape XML special characters when needed:

```text
&  = &amp;
"  = &quot;
<  = &lt;
>  = &gt;
```

## Complete `server_config.xml` Options

This reference is based on the SuperTuxKart `1.5` server config definitions. You can edit existing entries or add missing entries inside:

```xml
<server-config version="6" >
    ...
</server-config>
```

Use lowercase boolean values:

```text
true
false
```

### Full XML Template

This template includes all known STK `1.5` server config options:

```xml
<?xml version="1.0"?>
<server-config version="6" >
    <server-name value="{gameserver.list_name}" />
    <server-port value="{gameserver.game_port}" />
    <server-mode value="3" />
    <server-difficulty value="0" />
    <gp-track-count value="3" />
    <soccer-goal-target value="false" />
    <wan-server value="true" />
    <enable-console value="false" />
    <server-max-players value="{gameserver.slot_limit}" />
    <max-players-in-game value="20" />
    <private-server-password value="" />
    <motd value="Welcome to {gameserver.list_name}!" />
    <chat value="true" />
    <chat-consecutive-interval value="8" />
    <track-voting value="true" />
    <voting-timeout value="30" />
    <validation-timeout value="20" />
    <validating-player value="true" />
    <firewalled-server value="true" />
    <ipv6-connection value="true" />
    <owner-less value="false" />
    <start-game-counter value="60" />
    <official-karts-threshold value="1.0" />
    <official-tracks-threshold value="0.7" />
    <min-start-game-players value="2" />
    <auto-end value="false" />
    <team-choosing value="true" />
    <strict-players value="false" />
    <ranked value="false" />
    <server-configurable value="false" />
    <live-spectate value="true" />
    <real-addon-karts value="true" />
    <flag-return-timeout value="20" />
    <flag-deactivated-time value="3" />
    <hit-limit value="20" />
    <time-limit-ffa value="360" />
    <capture-limit value="5" />
    <time-limit-ctf value="600" />
    <auto-game-time-ratio value="-1" />
    <max-ping value="300" />
    <jitter-tolerance value="100" />
    <kick-high-ping-players value="false" />
    <high-ping-workaround value="true" />
    <kick-idle-player-seconds value="60" />
    <state-frequency value="10" />
    <sql-management value="false" />
    <database-file value="stkservers.db" />
    <database-timeout value="1000" />
    <ip-ban-table value="ip_ban" />
    <ipv6-ban-table value="ipv6_ban" />
    <online-id-ban-table value="online_id_ban" />
    <player-reports-table value="player_reports" />
    <player-reports-expired-days value="3" />
    <ip-geolocation-table value="ip_mapping" />
    <ipv6-geolocation-table value="ipv6_mapping" />
    <ai-handling value="false" />
    <ai-anywhere value="false" />
</server-config>
```

### Setting Reference

| Setting | Type | Default | Purpose |
| --- | --- | --- | --- |
| `server-name` | string | `STK Server` | Public/lobby server name. GSA can use `{gameserver.list_name}` here. |
| `server-port` | integer | `0` | Game port. Use `{gameserver.game_port}` in GSA. `0` lets STK choose its configured default. |
| `server-mode` | integer | `3` | Game mode. See mode values below. |
| `server-difficulty` | integer | `0` | Race difficulty. See difficulty values below. |
| `gp-track-count` | integer | `3` | Number of tracks in Grand Prix modes. |
| `soccer-goal-target` | boolean | `false` | Uses goal target behavior in Soccer mode. |
| `wan-server` | boolean | `true` | Enables WAN/public server listing. Requires a saved STK account session. |
| `enable-console` | boolean | `false` | Enables STK network console features. This blueprint does not expose a tested console panel. |
| `server-max-players` | integer | `8` | Total server/lobby capacity. Values above `8` may cost performance. |
| `max-players-in-game` | integer | `0` | Active racers per race. Extra players become spectators. `0` means all server players can race. |
| `private-server-password` | string | empty | Password required to join. Leave empty for public access. |
| `motd` | string | empty | Message shown in the lobby. Can also point to a `.txt` file. |
| `chat` | boolean | `true` | Allows or blocks player chat messages. |
| `chat-consecutive-interval` | integer | `8` | Chat flood protection window in seconds. Negative values disable this check. |
| `track-voting` | boolean | `true` | Allows players to vote for the next track. If false, the server chooses randomly. |
| `voting-timeout` | float | `30.0` | Seconds for kart selection and/or track voting. |
| `validation-timeout` | float | `20.0` | WAN validation timeout in seconds. |
| `validating-player` | boolean | `true` | Validates WAN players through STK services. Disable only if you intentionally allow non-validated WAN joins. |
| `firewalled-server` | boolean | `true` | Keeps STUN/firewall handling enabled. Disable only when your network setup does not need it. |
| `ipv6-connection` | boolean | `true` | Allows IPv6 connection handling when public IPv6 is available. |
| `owner-less` | boolean | `false` | Removes the lobby owner role. For this GSA setup, `false` is usually best. |
| `start-game-counter` | float | `60.0` | Auto-start countdown for ownerless or ranked servers once minimum players are present. |
| `official-karts-threshold` | float | `1.0` | Minimum official kart compatibility ratio required from clients. |
| `official-tracks-threshold` | float | `0.7` | Minimum official track compatibility ratio required from clients. Too high may block mobile clients. |
| `min-start-game-players` | integer | `2` | Minimum players required for auto-start on ownerless/ranked servers. |
| `auto-end` | boolean | `false` | Automatically ends linear races after the first finisher plus a grace period. |
| `team-choosing` | boolean | `true` | Allows team selection in Soccer and CTF modes. |
| `strict-players` | boolean | `false` | Blocks duplicate online IDs and split-screen players. Can limit network AI usage. |
| `ranked` | boolean | `false` | Enables STK ranking submission for permitted ranked servers. Requires project-side permission. |
| `server-configurable` | boolean | `false` | Lets the lobby owner change supported game mode/difficulty settings in the lobby. Not compatible with ownerless or Grand Prix servers. |
| `live-spectate` | boolean | `true` | Allows live join/spectate behavior where supported. Live joining is mainly for FFA, CTF, and Soccer. |
| `real-addon-karts` | boolean | `true` | Sends real addon kart physics to clients when available. |
| `flag-return-timeout` | float | `20.0` | Seconds before a dropped CTF flag returns to base. |
| `flag-deactivated-time` | float | `3.0` | Seconds a CTF flag is inactive after capture or return. |
| `hit-limit` | integer | `20` | Hit limit for Free-for-All. `0` disables the hit limit. |
| `time-limit-ffa` | integer | `360` | Free-for-All time limit in seconds. `0` disables the time limit. |
| `capture-limit` | integer | `5` | Capture limit for CTF. `0` disables the capture limit. |
| `time-limit-ctf` | integer | `600` | CTF time limit in seconds. `0` disables the time limit. |
| `auto-game-time-ratio` | float | `-1.0` | Automatically scales race laps or mode time. `-1` disables automatic scaling. |
| `max-ping` | integer | `300` | Maximum allowed ping in milliseconds. |
| `jitter-tolerance` | integer | `100` | Allowed network jitter in milliseconds. |
| `kick-high-ping-players` | boolean | `false` | Kicks players above `max-ping`. |
| `high-ping-workaround` | boolean | `true` | Allows high-ping players to remain playable. Disables high-ping kicking when enabled. |
| `kick-idle-player-seconds` | integer | `60` | Kicks players idle for this many seconds during games. Negative values disable it. |
| `state-frequency` | integer | `10` | Server state updates per second. Higher values use more bandwidth and client resources. |
| `sql-management` | boolean | `false` | Enables SQLite-backed server stats/maintenance if the STK build supports it. |
| `database-file` | string | `stkservers.db` | SQLite database filename. The database and required tables must exist for SQL features. |
| `database-timeout` | integer | `1000` | SQLite busy timeout in milliseconds. |
| `ip-ban-table` | string | `ip_ban` | IPv4 ban table name. Empty disables this table. |
| `ipv6-ban-table` | string | `ipv6_ban` | IPv6 ban table name. Empty disables this table. |
| `online-id-ban-table` | string | `online_id_ban` | Online ID ban table name. Empty disables this table. |
| `player-reports-table` | string | `player_reports` | Table for in-game player reports. Empty disables this table. |
| `player-reports-expired-days` | float | `3.0` | Days to keep player reports. `0` keeps them forever. |
| `ip-geolocation-table` | string | `ip_mapping` | IPv4 geolocation table name for non-STK-addons connections. Empty disables it. |
| `ipv6-geolocation-table` | string | `ipv6_mapping` | IPv6 geolocation table name for non-STK-addons connections. Empty disables it. |
| `ai-handling` | boolean | `false` | Lets the server manage network AI clients started with `--network-ai`. Use for non-GP racing servers. |
| `ai-anywhere` | boolean | `false` | Allows AI instances to connect from outside the LAN. Keep false for this local-container AI setup. |

### Mode Values

`server-mode` supports:

```text
0 = Normal Race Grand Prix
1 = Time Trial Grand Prix
3 = Normal Race
4 = Time Trial
6 = Soccer
7 = Free-for-All
8 = Capture the Flag
```

Modes `2` and `5` are not supported by the STK server code.

### Difficulty Values

`server-difficulty` supports:

```text
0 = Beginner
1 = Intermediate
2 = Expert
3 = SuperTux
```

### Common Lobby Settings

```xml
<track-voting value="true" />
<voting-timeout value="30" />
<owner-less value="false" />
<server-configurable value="false" />
<live-spectate value="true" />
<min-start-game-players value="2" />
<start-game-counter value="60" />
```

### Lobby Capacity Vs Active Race Size

Lobby capacity and active race size are separate settings:

```xml
<server-max-players value="{gameserver.slot_limit}" />
<max-players-in-game value="20" />
```

`server-max-players` controls how many players can be in the server/lobby. `max-players-in-game` controls how many can actively race; extra players become spectators. Use `0` to allow all server players into the active race, but `20` is the practical max race size for public lobbies.

One server instance runs one race/session at a time. Multiple races can happen sequentially in the same lobby, but simultaneous races require multiple server instances.

## AI Racers

To use local AI racers:

```text
AI Racers = 1 or higher
AI Handling = true
```

The wrapper starts a local headless STK client with `--network-ai` after the server starts.

Suggested starting point:

```text
AI Racers = 8
AI Handling = true
Ownerless Lobby = false
```

## Troubleshooting

If the server starts but does not appear publicly:

- Confirm `WAN/Public Server = true`.
- Confirm `Require STK Login = true`.
- Confirm valid STK account credentials are present.
- Reinstall/recreate the server after changing Docker environment variables.
- Confirm UDP ports `2757` and `2759` are reachable.

If AI racers join but the race does not start:

- Set `Ownerless Lobby = false`.
- Set `AI Handling = true`.
- Use lowercase boolean values in manually edited XML: `true` or `false`.
- Reinstall/recreate the server after changing Docker env values.

If GSA shows literal placeholders such as `{gameserver.list_name}` in a config parameter, place that placeholder directly in `server_config.xml` instead of nesting it inside another config parameter.

## Repository Files

- `blueprints/supertuxkart-gsa-windows.json` - import this into GameServerApp.
- `docker-run.gsa-import.txt` - simple Docker import seed command for GSA.
- `server_config.xml` - default STK server configuration.
- `Start.ps1` - container startup wrapper.
- `Dockerfile` - maintainer build definition for the published image.

## Maintainer Notes

Normal users do not need to build this image. The published GHCR image is intended to be consumed directly by GameServerApp or Docker.

If you are maintaining the image yourself, use the included GitHub Actions workflow to publish a new tag to GitHub Container Registry.
