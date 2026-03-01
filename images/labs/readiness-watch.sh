#!/bin/bash
kubectl get pods -l app=probe-example
echo ""
POD_NAMES=$(kubectl get pods -l app=probe-example | grep "Running" | awk '{print $1}')
for POD_NAME in $POD_NAMES; do echo "Last events for Pod $POD_NAME:"; kubectl describe pod $POD_NAME | tail -2; echo ""; done
