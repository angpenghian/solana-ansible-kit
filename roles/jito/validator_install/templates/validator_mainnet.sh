#!/bin/bash
export PATH="/home/sol/.local/share/solana/install/releases/{{ jito_install_version }}"/bin:"$PATH"

#BLOCK_ENGINE_URL=https://ny.mainnet.block-engine.jito.wtf
BLOCK_ENGINE_URL=https://slc.mainnet.block-engine.jito.wtf
#BLOCK_ENGINE_URL=https://amsterdam.mainnet.block-engine.jito.wtf
#BLOCK_ENGINE_URL=https://london.mainnet.block-engine.jito.wtf
#BLOCK_ENGINE_URL=https://frankfurt.mainnet.block-engine.jito.wtf

#RELAYER_URL=http://ny.mainnet.relayer.jito.wtf:8100
#RELAYER_URL=http://slc.mainnet.relayer.jito.wtf:8100
#RELAYER_URL=http://amsterdam.mainnet.relayer.jito.wtf:8100
#RELAYER_URL=http://london.mainnet.relayer.jito.wtf:8100
#RELAYER_URL=http://frankfurt.mainnet.relayer.jito.wtf:8100
#RELAYER_URL=http://185.191.118.82:11226
#RELAYER_URL=http://blackhole.relayer.jito.wtf:8100
RELAYER_URL=http://127.0.0.1:9999

#SHRED_RECEIVER_ADDR=141.98.216.96:1002
SHRED_RECEIVER_ADDR=64.130.53.8:1002
#SHRED_RECEIVER_ADDR=74.118.140.240:1002
#SHRED_RECEIVER_ADDR=142.91.127.175:1002
#SHRED_RECEIVER_ADDR=64.130.50.14:1002

export SOLANA_METRICS_CONFIG="host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password"

exec agave-validator \
    --tip-payment-program-pubkey T1pyyaTNZsKv2WcRAB8oVnk93mLJw2XzjtVYqCsaHqt \
    --tip-distribution-program-pubkey 4R3gSG8BpU4t19KYj8CfnbtRpnT8gtk4dvTHxVRwc2r7 \
    --merkle-root-upload-authority GZctHpWXmsZC1YHACTGGcHhYxjdRqQvTpYkb9LMvxDib \
    --commission-bps 400 \
    --relayer-url ${RELAYER_URL} \
    --block-engine-url ${BLOCK_ENGINE_URL} \
    --shred-receiver-address ${SHRED_RECEIVER_ADDR} \
    --identity /home/sol/validator-keypair.json \
    --vote-account /home/sol/vote-account-keypair.json \
    --authorized-voter /home/sol/keys/c000/validator-keypair.json \
    --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
    --known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
    --known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
    --known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
    --known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
    --only-known-rpc \
    --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
    --log /var/log/solana/solana-validator.log \
    --ledger /mnt/ledger \
    --accounts /mnt/accounts \
    --rpc-port 8899 \
    --rpc-bind-address 0.0.0.0 \
    --private-rpc \
    --dynamic-port-range 8000-8025 \
    --wal-recovery-mode skip_any_corrupted_record \
    --block-verification-method unified-scheduler \
    --no-snapshot-fetch \
    --limit-ledger-size