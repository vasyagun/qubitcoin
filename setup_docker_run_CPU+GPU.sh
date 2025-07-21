#!/bin/bash
set -e

WALLET="$1"
POOL="$2"

if [[ -z "$WALLET" || -z "$POOL" ]]; then
  echo "Usage: $0 <WALLET_ADDRESS> <POOL_ADDRESS>"
  exit 1
fi

docker pull vasyagun/qubitcoin-miner-cpu-gpu

docker run --rm --gpus all \
  -e WALLET="$WALLET" \
  -e POOL="$POOL" \
  vasyagun/qubitcoin-miner-cpu-gpu
