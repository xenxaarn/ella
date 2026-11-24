#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
IMG=localhost/ella:latest

sudo podman build --network=host --pull=newer -t $IMG .
mkdir -p output
sudo podman run --network=host --rm -it --privileged --pull=newer \
  --security-opt label=type:unconfined_t \
  -v ./config.toml:/config.toml:ro \
  -v ./output:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder@sha256:a829b782ecee4764edcac472d5672a76f20002143618fcfbd17dc1cc7319e642 \
  --type anaconda-iso \
  --rootfs xfs \
  "$IMG"

ls -lh output/bootiso/*.iso
