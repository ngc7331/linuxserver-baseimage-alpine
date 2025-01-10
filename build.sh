#!/bin/bash

set -e

VERSION=${VERSION:-3.21}
REPOS=(${REPOS:-ngc7331/linuxserver-baseimage-alpine})
OFFICIAL_REPO=lscr.io/linuxserver/baseimage-alpine
RISCV_REPO=ghcr.io/unofficial-docker-for-riscv/linuxserver-baseimage-alpine

echo "Building version: ${VERSION}"
echo "Building repos: ${REPOS[*]}"

# Check update
need_update=false
checkupdate() {
    repo=$1
    arch=$2
    echo "Checking update for ${arch}..."
    oldsha=$(docker buildx imagetools inspect --raw ${REPOS[0]}:${VERSION} | jq -r '.manifests[] | select(.platform.architecture == "'${arch}'") | .digest')
    echo "-> Old SHA (${REPOS[0]}:${VERSION}): ${oldsha}"
    newsha=$(docker buildx imagetools inspect --raw ${repo}:${VERSION} | jq -r '.manifests[] | select(.platform.architecture == "'${arch}'") | .digest')
    echo "-> New SHA (${repo}:${VERSION}): ${newsha}"
    if [ "${oldsha}" != "${newsha}" ]; then
        need_update=true
    fi
}
checkupdate ${OFFICIAL_REPO} amd64  # we don't have to check arm64
checkupdate ${RISCV_REPO} riscv64
if [[ "$need_update" == false ]]; then
    echo "No update needed"
    exit 0
fi

echo "Combining newer images..."
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
