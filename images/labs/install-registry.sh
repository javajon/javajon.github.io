#!/bin/bash

helm repo add twuni https://twuni.github.io/docker-registry.helm 

helm install registry twuni/docker-registry \
  --version 3.0.0 \
  --namespace kube-system \
  --set service.type=NodePort \
  --set service.nodePort=31500

kubectl wait --for=condition=Available deployment/registry-docker-registry  -n kube-system
