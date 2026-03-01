#!/bin/bash
set -e

# Set variables
REGISTRY_PREFIX=""  # Set this if you're using a container registry

# Build patient portal image
echo "Building patient-portal image..."
cd patient-portal-app
docker build -t ${REGISTRY_PREFIX}patient-portal:latest .
cd ..

# Build medical results image
echo "Building medical-data image..."
cd medical-data-app
docker build -t ${REGISTRY_PREFIX}medical-data:latest .
cd ..

# Create namespaces if they don't exist
kubectl get namespace patient-portal &>/dev/null || kubectl create namespace patient-portal
kubectl get namespace medical-data &>/dev/null || kubectl create namespace medical-data

# Deploy to Kubernetes
echo "Deploying patient-portal to Kubernetes..."
envsubst < patient-portal-deployment.yaml | kubectl apply -n patient-portal -f -
kubectl apply -n patient-portal -f patient-portal-service.yaml

echo "Deploying medical-data to Kubernetes..."
envsubst < medical-data-deployment.yaml | kubectl apply -n medical-data -f -
kubectl apply -n medical-data -f medical-data-service.yaml

echo "Deployment complete!"
