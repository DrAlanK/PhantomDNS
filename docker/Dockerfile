FROM debian:bookworm-slim AS downloader

ARG TARGETARCH
ARG TARGETVARIANT
ARG RELEASE_TAG=latest
ARG RELEASE_SHA256=

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  unzip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /out

RUN set -eux; \
  case "${TARGETARCH}" in \
  amd64) \
  ARTIFACT="phantomdns_Server_Linux_AMD64.zip"; PREFIX="phantomdns_Server_Linux_AMD64" ;; \
  arm64) \
  ARTIFACT="phantomdns_Server_Linux_ARM64.zip"; PREFIX="phantomdns_Server_Linux_ARM64" ;; \
  arm) \
  case "${TARGETVARIANT}" in \
  v5) ARTIFACT="phantomdns_Server_Linux_ARMV5.zip"; PREFIX="phantomdns_Server_Linux_ARMV5" ;; \
  v7|"") ARTIFACT="phantomdns_Server_Linux_ARMV7.zip"; PREFIX="phantomdns_Server_Linux_ARMV7" ;; \
  *) echo "Unsupported ARM variant: ${TARGETVARIANT}" >&2; exit 1 ;; \
  esac ;; \
  mips64le) \
  ARTIFACT="phantomdns_Server_Linux_MIPS64LE.zip"; PREFIX="phantomdns_Server_Linux_MIPS64LE" ;; \
  *) \
  echo "Unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  curl -fsSL --retry 3 --retry-delay 2 \
  -o /tmp/phantomdns.zip \
  "https://github.com/DrAlanK/phantomdns/releases/download/${RELEASE_TAG}/${ARTIFACT}"; \
  if [ -n "${RELEASE_SHA256}" ]; then \
  echo "${RELEASE_SHA256}  /tmp/phantomdns.zip" | sha256sum -c -; \
  fi; \
  unzip -q /tmp/phantomdns.zip -d /out; \
  rm -f /tmp/phantomdns.zip; \
  BIN="$(find /out -type f -name "${PREFIX}_v*" | sort -V | tail -n1)"; \
  if [ -z "${BIN}" ]; then echo "Could not find extracted binary for ${PREFIX}" >&2; exit 1; fi; \
  mv "${BIN}" /out/phantomdns; \
  chmod 0755 /out/phantomdns; \
  find /out -type f ! -path /out/phantomdns -delete

FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/DrAlanK/phantomdns

ENV DEBIAN_FRONTEND=noninteractive \
  APP_DIR=/opt/phantomdns \
  DATA_DIR=/data \
  CONFIG_FILE=server_config.toml \
  KEY_FILE=encrypt_key.txt

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  ca-certificates \
  curl \
  tini \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /opt/phantomdns /data

COPY --from=downloader /out/phantomdns /opt/phantomdns/phantomdns
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 0755 /opt/phantomdns/phantomdns /usr/local/bin/docker-entrypoint.sh

WORKDIR /opt/phantomdns

EXPOSE 53/tcp 53/udp
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["-nowait"]
