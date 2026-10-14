#!/bin/sh
set -eu

/opt/steamcmd/steamcmd.sh +force_install_dir /reforger/server +login anonymous +app_update 1874900 +quit

render-config.sh > /reforger/profile/config.json

cd /reforger/server
exec ./ArmaReforgerServer -config /reforger/profile/config.json -profile /reforger/profile -maxFPS "${MAX_FPS:-60}" "$@"
