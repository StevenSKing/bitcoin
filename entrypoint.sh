#!/bin/bash

set -e
: ${SERVER:=1}
: ${CONFIG:=/etc/bitcoin.conf}
: ${DATADIR:=/var/lib/bitcoin}
: ${RPCBIND:=$([[ -n $RPCUSER && -n $RPCPASSWORD || -n $RPCAUTH ]] && echo 0)}
: ${RPCALLOWIP:=$([[ -n $RPCUSER && -n $RPCPASSWORD || -n $RPCAUTH ]] && echo 0/0)}

touch /etc/bitcoin.conf
chmod og-rw /etc/bitcoin.conf
cat <<-:: >/etc/bitcoin.conf
	${SERVER:+server=$SERVER}
	${TESTNET:+testnet=$TESTNET}
	${TXINDEX:+txindex=$TXINDEX}
	${RPCUSER:+rpcuser=$RPCUSER}
	${RPCAUTH:+rpcauth=$RPCAUTH}
	${RPCALLOWIP:+rpcallowip=$RPCALLOWIP}
	${RPCPASSWORD:+rpcpassword=$RPCPASSWORD}
	${ALERTNOTIFY:+alertnotify=$ALERTNOTIFY}
	${BLOCKNOTIFY:+blocknotify=$BLOCKNOTIFY}
	${WALLETNOTIFY:+walletnotify=$WALLETNOTIFY}

	[main]
	${RPCPORT:+rpcport=$RPCPORT}
	${RPCBIND:+rpcbind=$RPCBIND}

	[test]
	${RPCPORT:+rpcport=$RPCPORT}
	${RPCBIND:+rpcbind=$RPCBIND}

	[regtest]
	${RPCPORT:+rpcport=$RPCPORT}
	${RPCBIND:+rpcbind=$RPCBIND}
::

mkdir -p "$DATADIR"
exec bitcoind -conf="$CONFIG" -datadir="$DATADIR" "$@"
