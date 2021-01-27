#!/bin/bash

kubectl -n lxcfs delete -f deployment/mutatingwebhook-ca-bundle.yaml
kubectl -n lxcfs delete -f deployment/service.yaml
kubectl -n lxcfs delete -f deployment/deployment.yaml
kubectl -n lxcfs delete secret lxcfs-admission-webhook-certs

