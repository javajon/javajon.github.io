#!/bin/bash

# About this custom script:
#   Contains all the commands that are specific to initializing this lab.
#   Called by the init-background.sh script. 
#   Any common background commands for all labs shall be made in init-common.sh
#   Any custom background commands for a specific lab shall be made in init-custom.sh
#   This file is a copied asset in index.yaml

# Fix permissions for the persistent volume directory on node01
# The container runs as user 1001 with group 1001, but is also member of group 1000
# Set up the directory with proper ownership so the application can write to it
# The hostPath volume is on node01, so we need to SSH there to fix permissions
ssh node01 "mkdir -p /data/pharmacy/data/refills && chown -R 1001:1000 /data/pharmacy && chmod -R 775 /data/pharmacy"