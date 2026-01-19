#!/bin/bash
export PATH="/home/sol/.local/share/solana/install/releases/{{ jito_upgrade_version }}"/bin:"$PATH"

#BLOCK_ENGINE_URL=https://ny.testnet.block-engine.jito.wtf
BLOCK_ENGINE_URL=https://slc.testnet.block-engine.jito.wtf
#BLOCK_ENGINE_URL=https://amsterdam.testnet.block-engine.jito.wtf
#BLOCK_ENGINE_URL=https://london.testnet.block-engine.jito.wtf

#RELAYER_URL=http://ny.testnet.relayer.jito.wtf:8100
RELAYER_URL=http://slc.testnet.relayer.jito.wtf:8100
#RELAYER_URL=http://amsterdam.testnet.relayer.jito.wtf:8100
#RELAYER_URL=http://london.testnet.relayer.jito.wtf:8100

#SHRED_RECEIVER_ADDR=141.98.216.96:1002
SHRED_RECEIVER_ADDR=64.130.53.8:1002
#SHRED_RECEIVER_ADDR=74.118.140.240:1002
#SHRED_RECEIVER_ADDR=142.91.127.175:1002

exec agave-validator \
    --tip-payment-program-pubkey GJHtFqM9agxPmkeKjHny6qiRKrXZALvvFGiKf11QE7hy \
    --tip-distribution-program-pubkey F2Zu7QZiTYUhPd7u9ukRVwxh7B71oA3NMJcHuCHc29P2 \
    --merkle-root-upload-authority 7heQNXEtxSv3wV8sNbuQsDN5xNGbbpLvHGiyXuJxEf7n \
    --commission-bps 10000 \
    --relayer-url ${RELAYER_URL} \
    --block-engine-url ${BLOCK_ENGINE_URL} \
    --shred-receiver-address ${SHRED_RECEIVER_ADDR} \
    --identity /home/sol/validator-keypair.json \
    --vote-account /home/sol/vote-account-keypair.json \
    --authorized-voter /home/sol/validator-keypair.json \
    --entrypoint entrypoint.testnet.solana.com:8001 \
    --entrypoint entrypoint2.testnet.solana.com:8001 \
    --entrypoint entrypoint3.testnet.solana.com:8001 \
    --known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
    --known-validator dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs \
    --known-validator Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN \
    --known-validator eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ \
    --known-validator 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv \
    --only-known-rpc \
    --expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
    --log /var/log/solana/solana-validator.log \
    --ledger /mnt/ledger \
    --accounts /mnt/accounts \
    --snapshots /mnt/snapshots \
    --rpc-port 8899 \
    --rpc-bind-address 0.0.0.0 \
    --private-rpc \
    --dynamic-port-range 8000-8025 \
    --wal-recovery-mode skip_any_corrupted_record \
    --block-verification-method unified-scheduler \
    --limit-ledger-size \
    --bam-url http://slc.testnet.bam.jito.wtf \
    --enable-rpc-transaction-history