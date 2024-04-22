FROM golang:1 AS builder

ENV TZ Asia/Shanghai

RUN set -ex \
    && apt update && apt upgrade -y && apt autoremove -y && apt autoclean -y \
    && apt install ca-certificates wget curl nload iftop htop unzip procps dnsutils iputils-ping git jq -y

COPY . /go/src/tpclash

RUN set -ex \
    && curl -sSL https://taskfile.dev/install.sh | bash -s -- -b /usr/bin \
    && cd /go/src/tpclash && task linux-$(dpkg --print-architecture) \
    && mv build/tpclash-linux-$(dpkg --print-architecture) /go/bin/tpclash

FROM debian:stable-slim AS dist

ENV TZ Asia/Shanghai

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt update && apt upgrade -y && apt autoremove -y && apt autoclean -y \
    && apt install tzdata ca-certificates curl iptables iproute2 -y \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/bin/tpclash /usr/local/bin/tpclash

VOLUME /etc/clash.yaml

CMD ["tpclash"]
