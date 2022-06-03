#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

ATOOOTCOIND=${ATOOOTCOIND:-$SRCDIR/atoootcoind}
ATOOOTCOINCLI=${ATOOOTCOINCLI:-$SRCDIR/atoootcoin-cli}
ATOOOTCOINTX=${ATOOOTCOINTX:-$SRCDIR/atoootcoin-tx}
ATOOOTCOINQT=${ATOOOTCOINQT:-$SRCDIR/qt/atoootcoin-qt}

[ ! -x $ATOOOTCOIND ] && echo "$ATOOOTCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
ATOOOTVER=($($ATOOOTCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$ATOOOTCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $ATOOOTCOIND $ATOOOTCOINCLI $ATOOOTCOINTX $ATOOOTCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${ATOOOTVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${ATOOOTVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
