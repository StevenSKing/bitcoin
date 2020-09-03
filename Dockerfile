FROM debian:buster-slim as base

FROM base as build
RUN apt-get update && apt-get install -y \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libevent-dev \
    libtool \
    libzmq3-dev \
    pkg-config \
    python3 \
    wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app/src
COPY contrib contrib
RUN ./contrib/install_db4.sh .

COPY Makefile.am .
COPY autogen.sh .
COPY build-aux build-aux
COPY configure.ac .
COPY doc doc
COPY libbitcoinconsensus.pc.in .
COPY share share
COPY src src
COPY test test
RUN ./autogen.sh \
  && ./configure --disable-tests \
    BDB_LIBS="-L/app/src/db4/lib -ldb_cxx-4.8" \
    BDB_CFLAGS="-I/app/src/db4/include" \
  && make -j$(nproc)

FROM base as final
RUN apt-get update && apt-get install -y \
    libboost-chrono1.67.0 \
    libboost-filesystem1.67.0 \
    libboost-system1.67.0 \
    libboost-thread1.67.0 \
    libevent-2.1-6 \
    libevent-pthreads-2.1-6 \
    libzmq5 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/src/src/bitcoind /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/bitcoind.sh

ENTRYPOINT ["bitcoind.sh"]
