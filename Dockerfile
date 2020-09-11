FROM debian:buster-slim as base
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

FROM base as deps
WORKDIR /usr/local/src/bitcoin
COPY contrib/install_db4.sh contrib/
RUN ./contrib/install_db4.sh .

FROM deps as build
COPY Makefile.am .
COPY autogen.sh .
COPY build-aux build-aux
COPY contrib contrib
COPY configure.ac .
COPY doc doc
COPY libbitcoinconsensus.pc.in .
COPY share share
COPY src src
COPY test test
RUN ./autogen.sh \
  && ./configure --disable-tests --disable-bench \
    BDB_LIBS="-L/usr/local/src/bitcoin/db4/lib -ldb_cxx" \
    BDB_CFLAGS=-I/usr/local/src/bitcoin/db4/include \
  && make -j$(nproc)

FROM debian:buster-slim as final
RUN apt-get update && apt-get install -y \
    libboost-chrono1.67.0 \
    libboost-filesystem1.67.0 \
    libboost-system1.67.0 \
    libboost-thread1.67.0 \
    libevent-2.1-6 \
    libevent-pthreads-2.1-6 \
    libzmq5 \
    wget \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build \
  /usr/local/src/bitcoin/src/bitcoind \
  /usr/local/src/bitcoin/src/bitcoin-tx \
  /usr/local/src/bitcoin/src/bitcoin-cli /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/bitcoind.sh

ENTRYPOINT ["bitcoind.sh"]
