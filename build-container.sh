#!/bin/bash
LXCFS_VERSION=latest
#docker build -t csighub.tencentyun.com/mulin/lxcfs:${LXCFS_VERSION} -f lxcfs-image/dockerfile.${LXCFS_VERSION} .
#docker push csighub.tencentyun.com/mulin/lxcfs:${LXCFS_VERSION}

docker build -t ccr.ccs.tencentyun.com/mulin-lxcfs/lxcfs:${LXCFS_VERSION} -f lxcfs-image/dockerfile.ccr.${LXCFS_VERSION} .
docker push ccr.ccs.tencentyun.com/mulin-lxcfs/lxcfs:${LXCFS_VERSION}

./build
