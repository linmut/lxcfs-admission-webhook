#!/bin/bash
docker build -t csighub.tencentyun.com/mulin/lxcfs:3.1.2 lxcfs-image
docker push csighub.tencentyun.com/mulin/lxcfs:3.1.2

./build
