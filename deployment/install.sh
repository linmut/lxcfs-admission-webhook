#!/bin/bash

#LIST_TYPE="balcklist"
LIST_TYPE="whitelist"

kubectl create ns lxcfs
./deployment/webhook-create-signed-cert.sh --namespace lxcfs
kubectl -n lxcfs get secret lxcfs-admission-webhook-certs

kubectl -n lxcfs create -f deployment/deployment.yaml
kubectl -n lxcfs create -f deployment/service.yaml
cat ./deployment/mutatingwebhook-${LIST_TYPE}.yaml | ./deployment/webhook-patch-ca-bundle.sh > ./deployment/mutatingwebhook-ca-bundle-${LIST_TYPE}.yaml
kubectl -n lxcfs create -f deployment/mutatingwebhook-ca-bundle-${LIST_TYPE}.yaml

