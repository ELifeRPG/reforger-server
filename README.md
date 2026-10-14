# reforger-server

Arma Reforger dedicated server image: `ghcr.io/eliferpg/reforger-server`.

The image ships SteamCMD only. On every start the entrypoint installs or updates the server
(Steam app `1874900`, ~10 GB) into `/reforger/server`, renders `config.json` from the environment
and the mods list, and starts `ArmaReforgerServer`. The server downloads and updates the listed workshop mods itself. Server binaries are never part of the image. CI rebuilds the image weekly
to pick up Debian and SteamCMD updates.

## Run

```sh
docker run -d --name reforger \
  -v reforger-server:/reforger/server \
  -v reforger-profile:/reforger/profile \
  -p 2001:2001/udp -p 17777:17777/udp \
  -v ./mods.json:/reforger/mods.json:ro \
  -e SERVER_NAME="ELifeRPG" -e ADMIN_PASSWORD=change-me \
  ghcr.io/eliferpg/reforger-server:latest
```

`/reforger/profile` holds the rendered config, logs, saves and downloaded workshop mods.

## Mods

Mount a JSON list at `/reforger/mods.json` (path overridable with `MODS_FILE`), see `mods.example.json`:

```json
[
  { "modId": "596AFBF40E2150FD", "name": "ELifeRPG" },
  { "modId": "5614BBCCBB55ED1C", "name": "Pinned dependency", "version": "1.0.0" }
]
```

`modId` is required; `name` is informational; `version` pins the mod, otherwise the latest is used.
IDs in `MODS` (comma-separated) are appended unless already in the file. An invalid file stops the
container before the server starts. Restart the container to apply changes.

## Environment

| Variable | Default | |
| --- | --- | --- |
| `SERVER_NAME` | `ELifeRPG` | Name in the server browser |
| `SERVER_PASSWORD` | | Join password |
| `ADMIN_PASSWORD` | | `#login` password for in-game admin |
| `SCENARIO_ID` | `{ECC61978EDCC2B5A}Missions/23_Campaign.conf` | Scenario resource |
| `MAX_PLAYERS` | `32` | |
| `MODS_FILE` | `/reforger/mods.json` | Mods list, see above |
| `MODS` | | Extra comma-separated workshop mod IDs |
| `PUBLIC_ADDRESS` | | Address advertised to the backend; auto-detected when empty |
| `GAME_PORT` | `2001` | Game UDP port |
| `PUBLIC_PORT` | `GAME_PORT` | Advertised port, when NAT maps it differently |
| `A2S_PORT` | `17777` | Steam query UDP port |
| `RCON_PASSWORD` | | Enables RCON on `RCON_PORT` (`19999`) when set |
| `BATTLEYE` | `true` | |
| `MAX_FPS` | `60` | Server tick cap |

Extra arguments to the container are passed to `ArmaReforgerServer`.

## Test the config locally

```sh
docker build -t reforger-server .
docker run --rm --entrypoint render-config.sh -v ./mods.example.json:/reforger/mods.json:ro reforger-server
```
