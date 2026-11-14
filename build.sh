#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
IMG=localhost/xen:latest

sudo podman build --network=host -t $IMG .
mkdir -p output
sudo podman run --network=host --rm -it --privileged --pull=newer \
  --security-opt label=type:unconfined_t \
  -v ./config.toml:/config.toml:ro \
  -v ./output:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type anaconda-iso \
  --rootfs xfs \
  "$IMG"

ls -lh output/bootiso/*.iso
