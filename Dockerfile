FROM python:3.8 AS base

ENV DEBIAN_FRONTEND=noninteractive

# install packages
RUN apt update &&\
    apt install -y git curl virtualenv npm nodejs iputils-ping dnsmasq &&\
    apt clean

ENV APP_DIR=/home/ubuntu

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

FROM base AS test-runner
ARG runner_dir
COPY $runner_dir /home/ubuntu/DPCTF
USER root
RUN chown -R ubuntu /home/ubuntu/DPCTF
USER ubuntu

USER root
RUN npm install --global https://github.com/cta-wave/wptreport.git#dpctf
USER ubuntu

FROM test-runner AS tests
COPY .cache/tests-rev.txt /dev/null
COPY remove-tests.sh .
RUN ./remove-tests.sh

ARG tests_dir
COPY $tests_dir /home/ubuntu/DPCTF/
USER root
RUN chown -R ubuntu /home/ubuntu/DPCTF
USER ubuntu

RUN echo "results/" >> .gitignore
RUN echo "config.json" >> .gitignore
RUN echo "certs/" >> .gitignore
RUN echo "reference-results/" >> .gitignore
RUN echo "content/" >> .gitignore
RUN echo "test-config.json" >> .gitignore
RUN echo "test-subsets.json" >> .gitignore

RUN ./wpt manifest --rebuild --no-download

EXPOSE 8000

ENV TEST_RUNNER_IP=127.0.0.1

CMD ln -s ../tests/* . ;\
    ./check-eula.sh &&\
    ./check-permissions.sh /home/ubuntu/DPCTF/results &&\
    ./check-host.sh /home/ubuntu/DPCTF/config.json &&\
    ./start-dns-server.sh &&\
    echo "Starting test server ..." &&\
    ./wpt serve-wave --report
