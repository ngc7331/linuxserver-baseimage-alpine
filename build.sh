#!/bin/bash

set -e

VERSION=${VERSION:-3.21}
REPOS=(${REPOS:-ngc7331/linuxserver-baseimage-alpine})
OFFICIAL_REPO=lscr.io/linuxserver/baseimage-alpine
RISCV_REPO=ghcr.io/unofficial-docker-for-riscv/linuxserver-baseimage-alpine

echo "Building version: ${VERSION}"
echo "Building repos: ${REPOS[*]}"

echo "Combining with images..."
TAGS=()
for repo in ${REPOS[@]}; do
    TAGS+=("-t ${repo}:${VERSION}")
    TAGS+=("-t ${repo}:${VERSION%.*}")
    TAGS+=("-t ${repo}:latest")
done
docker buildx imagetools create \
    ${OFFICIAL_REPO}:${VERSION} \
    ${RISCV_REPO}:${VERSION} \
    ${TAGS[*]}
