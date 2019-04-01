FROM node:8-alpine

ENV KD_VERSION=1.12.1
ENV KUBECTL_VERSION=1.12.3

RUN apk upgrade -q --no-cache
RUN apk add -q --no-cache \
  bash \
  ca-certificates \
  coreutils \
  curl \
  docker \
  gettext \
  git \
  grep \
  jq \
  make \
  openssl \
  py-pip \
  python \
  sed \
  gnupg \
  maven \
  nss \
  openjdk8 \
  zip \
 && pip install -q docker-compose

RUN wget -q "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -O "/usr/bin/kubectl" \
 && wget -q "https://github.com/UKHomeOffice/kd/releases/download/v${KD_VERSION}/kd_linux_amd64" -O "/usr/bin/kd" \
 && chmod +x "/usr/bin/kubectl" \
 && chmod +x "/usr/bin/kd"

CMD ["bash"]
