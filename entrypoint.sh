#!/bin/bash

set -e
cat <<-:: >/etc/bitcoin.conf
	server=1
	${TESTNET:+testnet=$TESTNET}
	${TXINDEX:+txindex=$TXINDEX}
	${RPCPORT:+rpcport=$RPCPORT}
	${RPCUSER:+rpcuser=$RPCUSER}
	${RPCAUTH:+rpcauth=$RPCAUTH}
	${RPCPASSWORD:+rpcpassword=$RPCPASSWORD}
::

mkdir -p /var/lib/bitcoin
exec bitcoind -conf=/etc/bitcoin.conf -datadir=/var/lib/bitcoin "$@"
