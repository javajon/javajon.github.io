#!/bin/bash

# This script is called by the solver script. Each function should be named solve_task_#, 
# where # is the number of the task each function will solve. The calling solver will call
# the corresponding verify_task_# function after each solver_task_# function completes. 

PROJECT_HOME=$HOME/projects/memcached-operator

function solve_task_1() {
  ./install-registry.sh
}


# https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#prerequisites
function solve_task_2() {
  ./install-operator-sdk.sh
}


# https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#create-a-new-project
function solve_task_3() {
  mkdir -p "$PROJECT_HOME"
  cd "$PROJECT_HOME" || return

  operator-sdk init --domain example.com --repo github.com/example/memcached-operator
}


# https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#create-a-new-api-and-controller
function solve_task_4() {
  cd "$PROJECT_HOME" || return
  operator-sdk create api --group cache --version v1alpha1 --kind Memcached --resource --controller
}


# Define the API: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#define-the-api
function solve_task_5() {
  TAIL="/}/"
  TOKEN=867-5309
  SOURCE=$PROJECT_HOME/api/v1alpha1/memcached_types.go
  cp -f -T --backup "$SOURCE"{,}

  HEAD="/type MemcachedSpec struct {/"  
  cat "$SOURCE" | sed "${HEAD},${TAIL}"c\ $TOKEN | sed "/${TOKEN}/r /root/MemcachedSpec.go" | sed "/${TOKEN}/d" > scratch.tmp && mv scratch.tmp $SOURCE

  HEAD="/type MemcachedStatus struct {/"
  cat "$SOURCE" | sed "${HEAD},${TAIL}"c\ $TOKEN | sed "/${TOKEN}/r /root/MemcachedStatus.go" | sed "/${TOKEN}/d" > scratch.tmp && mv scratch.tmp $SOURCE
}

# Regenerate the code based on the new CRD type
function solve_task_6() {
  cd "$PROJECT_HOME" || return
  make generate
}


# Generating CRD manifests: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#generating-crd-manifests
function solve_task_7() {
  cd "$PROJECT_HOME" || return
  make manifests
}


# Implement the Controller: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#implement-the-controller
function solve_task_8() {
  cd "$PROJECT_HOME" || return
  DESTINATION=$PROJECT_HOME/controllers
  cp --backup "$HOME/"memcached_controller.go "$DESTINATION"
  # make manifests
}


# Make container image of operator: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#configure-the-operators-image-registry
function solve_task_9() {
  cd "$PROJECT_HOME" || return
  export IMG=$REGISTRY/memcached-operator:0.0.1
  go get k8s.io/api/core/v1@v0.21.2
  make docker-build docker-push
}


# Run the Operator: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#run-the-operator
function solve_task_10() {
  cd "$PROJECT_HOME" || return
  export IMG=$REGISTRY/memcached-operator:0.0.1

  make deploy
}


# Create a Memcached cluster: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#create-a-memcached-cr
function solve_task_11() {
  sed 's/foo: bar/size: 3/g' $PROJECT_HOME/config/samples/cache_v1alpha1_memcached.yaml > $HOME/memcached.yaml
  kubectl apply -f $HOME/memcached.yaml
}


# Update size of cluster: https://v1-11-x.sdk.operatorframework.io/docs/building-operators/golang/tutorial/#update-the-size
function solve_task_12() {
  sed 's/foo: bar/size: 5/g' $PROJECT_HOME/config/samples/cache_v1alpha1_memcached.yaml > $HOME/memcached.yaml
  kubectl apply -f $HOME/memcached.yaml
}
