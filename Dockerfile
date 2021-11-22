FROM ubuntu:18.04

# install packages
RUN apt update &&\
    apt install git curl python python-pip virtualenv npm nodejs iputils-ping dnsmasq -y &&\
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

COPY check-permissions.sh .
RUN sed -i -e 's/\r$//' check-permissions.sh
COPY check-content.sh .
RUN sed -i -e 's/\r$//' check-content.sh
COPY check-host.sh .
RUN sed -i -e 's/\r$//' check-host.sh

ARG tests-rev

RUN ./import-tests.sh

EXPOSE 8000

ENV TEST_RUNNER_IP 127.0.0.1

CMD ln -s ../tests/* . ;\
  ./check-permissions.sh /home/ubuntu/DPCTF/results &&\
  ./check-host.sh /home/ubuntu/DPCTF/config.json &&\
   dnsmasq \
   --no-hosts \
   --address=/www1.xn--n8j6ds53lwwkrqhv28a.web-platform.test/$TEST_RUNNER_IP \
   --address=/op88.web-platform.test/$TEST_RUNNER_IP \
   --address=/op36.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op53.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op50.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.www.web-platform.test/$TEST_RUNNER_IP \
   --address=/op98.web-platform.test/$TEST_RUNNER_IP \
   --address=/op24.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op31.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op95.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op85.web-platform.test/$TEST_RUNNER_IP \
   --address=/op83.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.www.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op73.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op8.web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.www2.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op89.web-platform.test/$TEST_RUNNER_IP \
   --address=/op66.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.web-platform.test/$TEST_RUNNER_IP \
   --address=/op19.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.www2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op72.web-platform.test/$TEST_RUNNER_IP \
   --address=/op24.web-platform.test/$TEST_RUNNER_IP \
   --address=/op21.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op41.web-platform.test/$TEST_RUNNER_IP \
   --address=/op79.web-platform.test/$TEST_RUNNER_IP \
   --address=/op81.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op70.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.xn--lve-6lad.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op78.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op6.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.www.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op40.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op25.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op3.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op65.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op91.web-platform.test/$TEST_RUNNER_IP \
   --address=/www.www2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op80.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op59.web-platform.test/$TEST_RUNNER_IP \
   --address=/op52.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.xn--lve-6lad.web-platform.test/$TEST_RUNNER_IP \
   --address=/op68.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op45.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op71.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op72.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.www2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op39.web-platform.test/$TEST_RUNNER_IP \
   --address=/op90.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op60.web-platform.test/$TEST_RUNNER_IP \
   --address=/op58.web-platform.test/$TEST_RUNNER_IP \
   --address=/op28.web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.xn--lve-6lad.web-platform.test/$TEST_RUNNER_IP \
   --address=/op14.web-platform.test/$TEST_RUNNER_IP \
   --address=/op89.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op69.web-platform.test/$TEST_RUNNER_IP \
   --address=/op49.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op40.web-platform.test/$TEST_RUNNER_IP \
   --address=/op2.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op5.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www.www2.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op77.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www.xn--n8j6ds53lwwkrqhv28a.web-platform.test/$TEST_RUNNER_IP \
   --address=/op7.web-platform.test/$TEST_RUNNER_IP \
   --address=/op74.web-platform.test/$TEST_RUNNER_IP \
   --address=/op79.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op82.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www.www1.web-platform.test/$TEST_RUNNER_IP \
   --address=/op12.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op39.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op31.web-platform.test/$TEST_RUNNER_IP \
   --address=/www.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www.www.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op44.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.www1.web-platform.test/$TEST_RUNNER_IP \
   --address=/op58.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op14.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op30.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op62.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op61.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op92.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.xn--lve-6lad.web-platform.test/$TEST_RUNNER_IP \
   --address=/op29.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op18.web-platform.test/$TEST_RUNNER_IP \
   --address=/op73.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.xn--n8j6ds53lwwkrqhv28a.web-platform.test/$TEST_RUNNER_IP \
   --address=/op77.web-platform.test/$TEST_RUNNER_IP \
   --address=/op12.web-platform.test/$TEST_RUNNER_IP \
   --address=/op54.web-platform.test/$TEST_RUNNER_IP \
   --address=/op63.web-platform.test/$TEST_RUNNER_IP \
   --address=/op71.web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.www1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op95.web-platform.test/$TEST_RUNNER_IP \
   --address=/op16.web-platform.test/$TEST_RUNNER_IP \
   --address=/op36.web-platform.test/$TEST_RUNNER_IP \
   --address=/op27.web-platform.test/$TEST_RUNNER_IP \
   --address=/www.www.web-platform.test/$TEST_RUNNER_IP \
   --address=/op98.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op64.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op29.web-platform.test/$TEST_RUNNER_IP \
   --address=/op9.web-platform.test/$TEST_RUNNER_IP \
   --address=/op26.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op22.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op94.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.www2.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op44.web-platform.test/$TEST_RUNNER_IP \
   --address=/op94.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op33.web-platform.test/$TEST_RUNNER_IP \
   --address=/op38.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op33.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op84.web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.www1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op23.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op57.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op54.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op85.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.www2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op46.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op97.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op32.web-platform.test/$TEST_RUNNER_IP \
   --address=/op61.web-platform.test/$TEST_RUNNER_IP \
   --address=/op70.web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op32.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op60.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op4.web-platform.test/$TEST_RUNNER_IP \
   --address=/op43.web-platform.test/$TEST_RUNNER_IP \
   --address=/op7.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op78.web-platform.test/$TEST_RUNNER_IP \
   --address=/op26.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.xn--n8j6ds53lwwkrqhv28a.web-platform.test/$TEST_RUNNER_IP \
   --address=/op96.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op51.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op41.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op76.web-platform.test/$TEST_RUNNER_IP \
   --address=/op52.web-platform.test/$TEST_RUNNER_IP \
   --address=/op99.web-platform.test/$TEST_RUNNER_IP \
   --address=/op35.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op99.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op86.web-platform.test/$TEST_RUNNER_IP \
   --address=/not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op42.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op46.web-platform.test/$TEST_RUNNER_IP \
   --address=/op67.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op17.web-platform.test/$TEST_RUNNER_IP \
   --address=/op90.web-platform.test/$TEST_RUNNER_IP \
   --address=/op93.web-platform.test/$TEST_RUNNER_IP \
   --address=/op37.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op48.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op10.web-platform.test/$TEST_RUNNER_IP \
   --address=/op55.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op4.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.xn--n8j6ds53lwwkrqhv28a.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op55.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.www2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op47.web-platform.test/$TEST_RUNNER_IP \
   --address=/op51.web-platform.test/$TEST_RUNNER_IP \
   --address=/op45.web-platform.test/$TEST_RUNNER_IP \
   --address=/op80.web-platform.test/$TEST_RUNNER_IP \
   --address=/op68.web-platform.test/$TEST_RUNNER_IP \
   --address=/op49.web-platform.test/$TEST_RUNNER_IP \
   --address=/op57.web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.xn--n8j6ds53lwwkrqhv28a.web-platform.test/$TEST_RUNNER_IP \
   --address=/www.xn--n8j6ds53lwwkrqhv28a.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op56.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/web-platform.test/$TEST_RUNNER_IP \
   --address=/op84.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.xn--n8j6ds53lwwkrqhv28a.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op34.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op6.web-platform.test/$TEST_RUNNER_IP \
   --address=/op35.web-platform.test/$TEST_RUNNER_IP \
   --address=/op67.web-platform.test/$TEST_RUNNER_IP \
   --address=/op69.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op11.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op93.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.www.web-platform.test/$TEST_RUNNER_IP \
   --address=/op86.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op8.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.xn--n8j6ds53lwwkrqhv28a.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op92.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.www1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op15.web-platform.test/$TEST_RUNNER_IP \
   --address=/op13.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op13.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.www.web-platform.test/$TEST_RUNNER_IP \
   --address=/op75.web-platform.test/$TEST_RUNNER_IP \
   --address=/op20.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op76.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op64.web-platform.test/$TEST_RUNNER_IP \
   --address=/op97.web-platform.test/$TEST_RUNNER_IP \
   --address=/op37.web-platform.test/$TEST_RUNNER_IP \
   --address=/op56.web-platform.test/$TEST_RUNNER_IP \
   --address=/op62.web-platform.test/$TEST_RUNNER_IP \
   --address=/op82.web-platform.test/$TEST_RUNNER_IP \
   --address=/op25.web-platform.test/$TEST_RUNNER_IP \
   --address=/op11.web-platform.test/$TEST_RUNNER_IP \
   --address=/www.xn--lve-6lad.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.www1.web-platform.test/$TEST_RUNNER_IP \
   --address=/op27.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op50.web-platform.test/$TEST_RUNNER_IP \
   --address=/op17.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op38.web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.www.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.www1.web-platform.test/$TEST_RUNNER_IP \
   --address=/op75.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op83.web-platform.test/$TEST_RUNNER_IP \
   --address=/op81.web-platform.test/$TEST_RUNNER_IP \
   --address=/op15.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.www.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op20.web-platform.test/$TEST_RUNNER_IP \
   --address=/op3.web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.www2.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.xn--n8j6ds53lwwkrqhv28a.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op2.web-platform.test/$TEST_RUNNER_IP \
   --address=/op21.web-platform.test/$TEST_RUNNER_IP \
   --address=/op23.web-platform.test/$TEST_RUNNER_IP \
   --address=/op42.web-platform.test/$TEST_RUNNER_IP \
   --address=/op47.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.www1.web-platform.test/$TEST_RUNNER_IP \
   --address=/op18.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op22.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.xn--lve-6lad.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op63.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op28.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op65.web-platform.test/$TEST_RUNNER_IP \
   --address=/www.www1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.xn--lve-6lad.web-platform.test/$TEST_RUNNER_IP \
   --address=/op43.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op66.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.www.web-platform.test/$TEST_RUNNER_IP \
   --address=/op96.web-platform.test/$TEST_RUNNER_IP \
   --address=/op91.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www.xn--lve-6lad.web-platform.test/$TEST_RUNNER_IP \
   --address=/op1.web-platform.test/$TEST_RUNNER_IP \
   --address=/op74.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op87.web-platform.test/$TEST_RUNNER_IP \
   --address=/op59.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op19.web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--n8j6ds53lwwkrqhv28a.www1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op9.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op88.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op53.web-platform.test/$TEST_RUNNER_IP \
   --address=/www2.xn--lve-6lad.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op87.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op30.web-platform.test/$TEST_RUNNER_IP \
   --address=/op10.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op48.web-platform.test/$TEST_RUNNER_IP \
   --address=/op16.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/op34.web-platform.test/$TEST_RUNNER_IP \
   --address=/op1.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/www.web-platform.test/$TEST_RUNNER_IP \
   --address=/op5.web-platform.test/$TEST_RUNNER_IP \
   --address=/www1.xn--lve-6lad.not-web-platform.test/$TEST_RUNNER_IP \
   --address=/xn--lve-6lad.www2.not-web-platform.test/$TEST_RUNNER_IP \
   && ./wpt serve-wave --report
