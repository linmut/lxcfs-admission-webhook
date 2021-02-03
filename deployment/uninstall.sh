#!/bin/bash
#LIST_TYPE="balcklist"
LIST_TYPE="whitelist"

kubectl -n lxcfs delete -f deployment/mutatingwebhook-ca-bundle-${LIST_TYPE}.yaml
kubectl -n lxcfs delete -f deployment/service.yaml
kubectl -n lxcfs delete -f deployment/deployment.yaml
kubectl -n lxcfs delete secret lxcfs-admission-webhook-certs

