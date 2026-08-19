#!/bin/bash

# About this custom script:
#   Contains all the commands that are specific to initializing this lab.
#   Called by the init-background.sh script. 
#   Any common background commands for all labs shall be made in init-common.sh
#   Any custom background commands for a specific lab shall be made in init-custom.sh
#   This file is a copied asset in index.yaml

# Inject Kubernetes external ip into katacoda.yaml
export EXTERNAL_IP=$(kubectl cluster-info | grep 'control plane' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
envsubst < /root/katacoda-template.yaml > /root/katacoda.yaml
rm /root/katacoda-template.yaml

# Install missing packages:
safe_install npm