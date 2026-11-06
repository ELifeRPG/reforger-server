FROM debian:trixie-slim

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl jq lib32gcc-s1 libcurl4t64 libssl3t64 \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1000 reforger \
 && mkdir -p /opt/steamcmd /reforger/server /reforger/profile \
 && curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steamcmd \
 && chown -R reforger:reforger /opt/steamcmd /reforger

COPY --chmod=755 scripts/entrypoint.sh scripts/render-config.sh /usr/local/bin/

USER reforger
WORKDIR /reforger
# steamcmd updates itself on every container start (see entrypoint.sh), so the
# build only checks that its 32-bit libraries resolve. That check needs no
# network access to Steam, which GitHub-hosted runners can't reliably reach.
RUN ! ldd /opt/steamcmd/linux32/steamcmd | grep 'not found'

VOLUME ["/reforger/server", "/reforger/profile"]
EXPOSE 2001/udp 17777/udp 19999/udp

ENTRYPOINT ["entrypoint.sh"]
