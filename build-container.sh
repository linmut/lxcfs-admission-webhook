#!/bin/bash
LXCFS_VERSION=3.1.2
docker build -t csighub.tencentyun.com/mulin/lxcfs:${LXCFS_VERSION} lxcfs-image/dockerfile.${LXCFS_VERSION} .
docker push csighub.tencentyun.com/mulin/lxcfs:${LXCFS_VERSION}

./build
