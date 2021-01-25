#!/bin/bash
docker build -t csighub.tencentyun.com/mulin/lxcfs:4.0.0 lxcfs-image
docker push csighub.tencentyun.com/mulin/lxcfs:4.0.0

./build
