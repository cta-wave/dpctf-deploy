FROM python:3.8

ENV DEBIAN_FRONTEND=noninteractive

# install packages
RUN apt update &&\
    apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget ca-certificates llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8 &&\
    apt install -y git curl virtualenv npm nodejs iputils-ping dnsmasq &&\
    apt clean

ENV APP_DIR /home/ubuntu

RUN mkdir $APP_DIR &&\ 
    useradd -d $APP_DIR ubuntu &&\
    chown -R ubuntu $APP_DIR
WORKDIR $APP_DIR
RUN rm /bin/sh &&\
    ln -s /bin/bash /bin/sh
USER ubuntu

RUN mkdir tests
RUN mkdir DPCTF && cd DPCTF
WORKDIR DPCTF
RUN git init &&\
    git remote add origin https://github.com/cta-wave/dpctf-test-runner.git

USER root
RUN npm install --global https://github.com/cta-wave/wptreport.git#dpctf
USER ubuntu

ARG commit
ARG runner-rev

RUN git fetch origin $commit
RUN git reset --hard FETCH_HEAD


ARG tests-rev
ARG testsbranch

RUN ./import-tests.sh "$testsbranch"

COPY check-permissions.sh .
RUN sed -i -e 's/\r$//' check-permissions.sh
COPY check-content.sh .
RUN sed -i -e 's/\r$//' check-content.sh
COPY check-host.sh .
RUN sed -i -e 's/\r$//' check-host.sh
COPY check-eula.sh .
RUN sed -i -e 's/\r$//' check-eula.sh
COPY start-dns-server.sh .
RUN sed -i -e 's/\r$//' start-dns-server.sh

EXPOSE 8000

ENV TEST_RUNNER_IP 127.0.0.1

CMD ln -s ../tests/* . ;\
    ./check-eula.sh &&\
    ./check-permissions.sh /home/ubuntu/DPCTF/results &&\
    ./check-host.sh /home/ubuntu/DPCTF/config.json &&\
    ./start-dns-server.sh &&\
    echo "Starting test server ..." &&\
    ./wpt serve-wave --report
