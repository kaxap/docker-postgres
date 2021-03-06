FROM postgres:10

# Based on https://hub.docker.com/r/abakpress/postgres-db/~/dockerfile/

RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq \
    && apt-get install -yq --no-install-recommends \
    ca-certificates \
    libpq-dev \
    postgresql-server-dev-all \
    postgresql-common \
    wget \
    unzip \
    make \
    build-essential \
    libssl-dev \
    libkrb5-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

COPY v3.2.1.zip /tmp/
COPY v1.3.3.zip /tmp/

RUN cd /tmp \
    && unzip v1.3.3.zip \
    && make -C pg_jobmon-1.3.3 \
    && make NO_BGW=1 install -C pg_jobmon-1.3.3 \
    && rm v1.3.3.zip \
    && rm -rf pg_jobmon-1.3.3

RUN cd /tmp \
    && unzip v3.2.1.zip \
    && make -C pg_partman-3.2.1 \
    && make install -C pg_partman-3.2.1 \
    && rm v3.2.1.zip \
    && rm -rf pg_partman-3.2.1

ENV PATH /usr/bin:$PATH

COPY initdb.sh /docker-entrypoint-initdb.d/
COPY postgresql.conf ./
