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
  python3 \
  python3-dev \
  sed \
  gnupg \
  maven \
  nss \
  openjdk8 \
  zip \
 && pip install -q --upgrade pip \
 && pip install -q docker-compose

# create a python3 virtual environment with troposphere, dependencies and aws-cli
COPY troposphere-requirements.txt /
RUN python3 -m venv /troposphere && \
  source /troposphere/bin/activate && \
  pip install -q -r /troposphere-requirements.txt && \
  deactivate

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

# git needs perl to do pull requests from the command line.
RUN apk add -q --no-cache perl && \
 git config --global user.email "cdp@homeoffice.gov.uk" && \
 git config --global user.name "CDP"

CMD ["bash"]

FROM build as test
ARG GIT_DEPLOYMENT_KEY
ENV GIT_DEPLOYMENT_KEY=$GIT_DEPLOYMENT_KEY
ARG GIT_DEPLOYMENT_KEY_AUTO_DEPLOY_TEMP
ENV GIT_DEPLOYMENT_KEY_AUTO_DEPLOY_TEMP=$GIT_DEPLOYMENT_KEY_AUTO_DEPLOY_TEMP
RUN echo 'Beginning tests'
RUN cd / && git clone https://github.com/sstephenson/bats.git &&  cd bats && ./install.sh /usr/local
ADD tests /tests
RUN set -e && for i in /tests/*.sh; do echo "$i" && $i; done

FROM build
