FROM node:8-alpine

ENV KUBECTL_VERSION=1.12.3

RUN apk upgrade -q --no-cache
RUN apk add -q --no-cache \
  bash \
  ca-certificates \
  coreutils \
  curl \
  docker \
  gcc \
  gettext \
  git \
  grep \
  jq \
  libffi \
  libffi-dev \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  py-pip \
  python \
  python-dev \
  sed \
  gnupg \
  maven \
  nss \
  openjdk8 \
  zip \
 && pip install -q --upgrade pip \
 && pip install -q docker-compose

RUN wget -q "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -O "/usr/bin/kubectl" \
 && chmod +x "/usr/bin/kubectl"

CMD ["bash"]
