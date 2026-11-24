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
  quay.io/centos-bootc/bootc-image-builder@sha256:195a21085a38088ba42d18b1875a05b9c2449750f3fb28e08f07e585bfb8ec51 \
  --type anaconda-iso \
  --rootfs xfs \
  "$IMG"

ls -lh output/bootiso/*.iso
