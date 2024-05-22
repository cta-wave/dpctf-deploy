FROM python:3.8 AS base

ENV DEBIAN_FRONTEND=noninteractive

# install packages
RUN apt update &&\
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

RUN mkdir tests DPCTF && cd DPCTF
WORKDIR /home/ubuntu/DPCTF

COPY check-permissions.sh \
 check-content.sh \
 check-host.sh \
 check-eula.sh \
 start-dns-server.sh /home/ubuntu/DPCTF/

RUN sed -i -e 's/\r$//' check-permissions.sh \
 check-content.sh \
 check-host.sh \
 check-eula.sh \
 start-dns-server.sh

RUN git init &&\
    git remote add origin https://github.com/cta-wave/dpctf-test-runner.git

FROM base AS test-runner
COPY cache/runner-rev.txt /dev/null

USER root
RUN npm install --global https://github.com/cta-wave/wptreport.git#dpctf
USER ubuntu

ARG commit

RUN git fetch origin $commit && \
 git reset --hard FETCH_HEAD && \
 rm -rf .git


FROM test-runner AS tests
COPY cache/tests-rev.txt /dev/null

ARG testsbranch
RUN ./import-tests.sh "$testsbranch"

RUN ./wpt manifest --rebuild --no-download

EXPOSE 8000

ENV TEST_RUNNER_IP 127.0.0.1

CMD ln -s ../tests/* . ;\
    ./check-eula.sh &&\
    ./check-permissions.sh /home/ubuntu/DPCTF/results &&\
    ./check-host.sh /home/ubuntu/DPCTF/config.json &&\
    ./start-dns-server.sh &&\
    echo "Starting test server ..." &&\
    ./wpt serve-wave --report
