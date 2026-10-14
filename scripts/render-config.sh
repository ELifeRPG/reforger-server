#!/bin/sh
set -eu

default_scenario='{ECC61978EDCC2B5A}Missions/23_Campaign.conf'
mods_file="${MODS_FILE:-/reforger/mods.json}"

if [ -f "$mods_file" ]; then
  file_mods=$(jq -c '
    if type == "array" and all(.[]; type == "object" and (.modId | type) == "string" and .modId != "")
    then map({ modId, name, version } | with_entries(select(.value != null)))
    else error("must be an array of objects with a modId")
    end' "$mods_file") || { echo "invalid mods file $mods_file" >&2; exit 1; }
else
  file_mods='[]'
fi

jq -n \
  --arg name "${SERVER_NAME:-ELifeRPG}" \
  --arg password "${SERVER_PASSWORD:-}" \
  --arg passwordAdmin "${ADMIN_PASSWORD:-}" \
  --arg scenarioId "${SCENARIO_ID:-$default_scenario}" \
  --argjson maxPlayers "${MAX_PLAYERS:-32}" \
  --arg publicAddress "${PUBLIC_ADDRESS:-}" \
  --argjson bindPort "${GAME_PORT:-2001}" \
  --argjson publicPort "${PUBLIC_PORT:-${GAME_PORT:-2001}}" \
  --argjson a2sPort "${A2S_PORT:-17777}" \
  --argjson rconPort "${RCON_PORT:-19999}" \
  --arg rconPassword "${RCON_PASSWORD:-}" \
  --argjson fileMods "$file_mods" \
  --arg mods "${MODS:-}" \
  --argjson battlEye "${BATTLEYE:-true}" \
  '{
    bindAddress: "0.0.0.0",
    bindPort: $bindPort,
    publicAddress: $publicAddress,
    publicPort: $publicPort,
    a2s: { address: "0.0.0.0", port: $a2sPort },
    game: {
      name: $name,
      password: $password,
      passwordAdmin: $passwordAdmin,
      scenarioId: $scenarioId,
      maxPlayers: $maxPlayers,
      visible: true,
      gameProperties: { battlEye: $battlEye },
      mods: ($fileMods + ($mods | split(",") | map(gsub("\\s"; "")) | map(select(. != "")) | unique
        | map(select(. as $id | $fileMods | all(.modId != $id))) | map({ modId: . })))
    }
  }
  + if $rconPassword == "" then {} else { rcon: { address: "0.0.0.0", port: $rconPort, password: $rconPassword, permission: "admin" } } end'
