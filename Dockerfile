FROM alpine as build

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
  libffi \
  libffi-dev \
  make \
  musl-dev \
  openssh-client \
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

RUN curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | \
  grep browser_download | \
  grep linux | \
  cut -d '"' -f 4 | \
  xargs curl -O -L && \
mv kustomize_*_linux_amd64 /usr/bin/kustomize && \
chmod u+x /usr/bin/kustomize

ADD deployment-scripts /usr/bin/

CMD ["bash"]

FROM build as test
RUN echo 'Beginning tests'
RUN cd / && git clone https://github.com/sstephenson/bats.git &&  cd bats && ./install.sh /usr/local
ADD tests /tests
RUN set -e && for i in /tests/*.sh; do $i; done

FROM build
