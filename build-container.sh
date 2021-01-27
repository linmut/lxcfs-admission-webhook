#!/bin/bash
docker build -t csighub.tencentyun.com/mulin/lxcfs:4.0.5 lxcfs-image
docker push csighub.tencentyun.com/mulin/lxcfs:4.0.5

./build
